package com.redhat.cloudnative.gateway;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.Single;
import io.vertx.core.http.HttpMethod;
import io.vertx.core.json.JsonArray;
import io.vertx.core.json.JsonObject;
import io.vertx.ext.web.client.WebClientOptions;
import io.vertx.reactivex.config.ConfigRetriever;
import io.vertx.reactivex.core.AbstractVerticle;
import io.vertx.reactivex.core.buffer.Buffer;
import io.vertx.reactivex.ext.web.Router;
import io.vertx.reactivex.ext.web.RoutingContext;
import io.vertx.reactivex.ext.web.client.HttpRequest;
import io.vertx.reactivex.ext.web.client.WebClient;
import io.vertx.reactivex.ext.web.client.predicate.ResponsePredicate;
import io.vertx.reactivex.ext.web.codec.BodyCodec;
import io.vertx.reactivex.ext.web.handler.CorsHandler;
import io.vertx.reactivex.ext.web.handler.StaticHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static com.redhat.cloudnative.gateway.HeadersPopulator.populateHeaders;

public class GatewayVerticle extends AbstractVerticle {
    private static final Logger LOG = LoggerFactory.getLogger(GatewayVerticle.class);

    private WebClient catalog;
    private WebClient inventory;

    @Override
    public void start() {
        Router router = Router.router(vertx);
        router.route().handler(CorsHandler.create("*").allowedMethod(HttpMethod.GET).allowedHeader("Ike-Session-Id"));
        router.get("/*").handler(StaticHandler.create("assets"));
        router.get("/health").handler(this::health);
        router.get("/api/products").handler(this::products);

        ConfigRetriever retriever = ConfigRetriever.create(vertx);
        retriever.getConfig(ar -> {
            if (ar.failed()) {
                LOG.warn("Failed to retrieve the configuration: {}", ar.cause().getMessage());
            } else {
                JsonObject config = ar.result();

                String catalogApiHost = config.getString("COMPONENT_CATALOG_HOST", "localhost");
                Integer catalogApiPort = config.getInteger("COMPONENT_CATALOG_PORT", 9001);

                catalog = WebClient.create(vertx,
                    new WebClientOptions()
                        .setDefaultHost(catalogApiHost)
                        .setDefaultPort(catalogApiPort));

                LOG.info("Catalog Service Endpoint: {}:{}", catalogApiHost, catalogApiPort);

                String inventoryApiHost = config.getString("COMPONENT_INVENTORY_HOST", "localhost");
                Integer inventoryApiPort = config.getInteger("COMPONENT_INVENTORY_PORT", 9001);

                inventory = WebClient.create(vertx,
                    new WebClientOptions()
                        .setDefaultHost(inventoryApiHost)
                        .setDefaultPort(inventoryApiPort));

                LOG.info("Inventory Service Endpoint: {}:{}", inventoryApiHost, inventoryApiPort);

                vertx.createHttpServer()
                    .requestHandler(router)
                    .listen(Integer.getInteger("http.port", 8080));

                LOG.info("Server is running on port {}", Integer.getInteger("http.port", 8080));
            }
        });
    }

    private void products(RoutingContext rc) {
        final HttpRequest<Buffer> getCatalog = catalog
            .get("/api/catalog");

        populateHeaders(getCatalog, rc)
            .expect(ResponsePredicate.SC_OK)
            .as(BodyCodec.jsonArray())
            .rxSend()
            .map(resp -> {
                // Map the response to a list of JSON object
                List<JsonObject> listOfProducts = new ArrayList<>();
                for (Object product : resp.body()) {
                    listOfProducts.add((JsonObject)product);
                }
                return listOfProducts;
            })
            .flatMap(products -> {
                    // For each item from the catalog, invoke the inventory service
                    // and create a JsonArray containing all the results
                    return Observable.fromIterable(products)
                        .flatMapSingle(product -> this.getAvailabilityFromInventory(product, rc))
                        .collect(JsonArray::new, JsonArray::add);
                }
            )
            .subscribe(
                list -> rc.response().end(list.encodePrettily()),
                error -> rc.response().setStatusCode(500).end(new JsonObject().put("error", error.getMessage()).toString())
            );
    }

    private Single<JsonObject> getAvailabilityFromInventory(JsonObject product, RoutingContext rc) {
        final HttpRequest<Buffer> getInventory = inventory
            .get("/api/inventory/" + product.getString("itemId"));
        return populateHeaders(getInventory, rc)
            .as(BodyCodec.jsonObject())
            .rxSend()
            .map(resp -> {
                if (resp.statusCode() != 200) {
                    LOG.warn("Inventory error for {}: status code {}",
                        product.getString("itemId"), resp.statusCode());
                    return product.copy();
                }
                return product.copy().put("availability",
                    new JsonObject().put("quantity", resp.body().getInteger("quantity")));
            });
    }

    private void health(RoutingContext rc) {
        // Check Catalog and Inventory Service up and running
        catalog.get("/").rxSend()
            .subscribe(
                catalogCallOk -> {
                    inventory.get("/").rxSend()
                        .subscribe(
                            inventoryCallOk -> rc.response().setStatusCode(200).end(new JsonObject().put("status", "UP").toString()),
                            error -> rc.response().setStatusCode(503).end(new JsonObject().put("status", "DOWN").toString())
                        );
                },
                error -> rc.response().setStatusCode(503).end(new JsonObject().put("status", "DOWN").toString())
            );
    }
}
