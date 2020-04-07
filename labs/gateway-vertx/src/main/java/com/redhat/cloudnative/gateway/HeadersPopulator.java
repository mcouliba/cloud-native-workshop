package com.redhat.cloudnative.gateway;

import java.util.Arrays;
import java.util.List;

import io.vertx.reactivex.core.MultiMap;
import io.vertx.reactivex.core.buffer.Buffer;
import io.vertx.reactivex.ext.web.RoutingContext;
import io.vertx.reactivex.ext.web.client.HttpRequest;

public class HeadersPopulator {
    private static final List<String> FORWARDED_HEADER_NAMES = Arrays.asList(
        "x-request-id",
        "x-b3-traceid",
        "x-b3-spanid",
        "x-b3-parentspanid",
        "x-b3-sampled",
        "x-b3-flags",
        "x-ot-span-context",
        "ike-session-id"
    );

    private HeadersPopulator() {
        // Avoid direct instantiation.
    }

    public static HttpRequest<Buffer> populateHeaders(HttpRequest<Buffer> request, RoutingContext ctx) {
        final MultiMap orgHeaders = ctx.request().headers();
        orgHeaders.names().stream()
            .map(String::toLowerCase)
            .filter(FORWARDED_HEADER_NAMES::contains)
            .forEach(s -> request.headers().add(s, orgHeaders.get(s)));
        return request;
    }

}
