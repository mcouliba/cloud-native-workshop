## Cursor Cloud specific instructions

### Overview

This is the **CoolStore** cloud-native workshop application — a polyglot microservices e-commerce demo. It consists of 4 required services that together form the full product catalog experience.

### Services

| Service | Tech | Directory | Default Port | Run Command |
|---|---|---|---|---|
| Inventory | Quarkus 1.7.2 (Java) | `labs/inventory-quarkus` | 8080 | `mvn compile quarkus:dev -Ddebug=false` |
| Catalog | Spring Boot 2.1.6 (Java) | `labs/catalog-spring-boot` | 9000 | `mvn spring-boot:run` |
| Gateway | Vert.x 3.6.3 (Java) | `labs/gateway-vertx` | 8090 (see note) | Build jar then `java -Dhttp.port=8090 -jar target/gateway-1.0-SNAPSHOT.jar` |
| Web UI | Node.js / AngularJS | `labs/web-nodejs` | 3000 | `COOLSTORE_GW_ENDPOINT=http://localhost:8090 PORT=3000 node .` |

### Prerequisites

- **JDK 11** — required for all Java services. Set `JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64` before running Maven commands. JDK 21 (default) is too new for the Red Hat BOM dependencies.
- **Maven 3.x** — installed via apt (`openjdk-11-jdk` and `maven` packages).
- **Node.js** — any recent LTS version works for the Web UI. Install deps with `npm install --ignore-scripts` (the `postinstall` hook for `license-reporter` can be skipped).

### Port configuration gotchas

- The Gateway Vert.x service ignores `-Dhttp.port` when run via `mvn vertx:run` because the plugin forks a new JVM. You must first `mvn clean package -DskipTests` then run the fat jar directly: `java -Dhttp.port=8090 -jar target/gateway-1.0-SNAPSHOT.jar`.
- The Gateway defaults to connecting to Catalog and Inventory on `localhost:9001`. Override via env vars: `COMPONENT_CATALOG_HOST`, `COMPONENT_CATALOG_PORT`, `COMPONENT_INVENTORY_HOST`, `COMPONENT_INVENTORY_PORT`.
- The Catalog Spring Boot service runs on port 9000 (configured in `pom.xml` jvmArguments: `-Dserver.port=9000`).
- The Web UI reads `COOLSTORE_GW_ENDPOINT` env var to know where the Gateway API lives.

### Databases

All services use **in-memory H2** by default — no external database setup is needed. Data is seeded from `import.sql` files in each service's resources.

### Testing

- `mvn test` in `labs/inventory-quarkus` — the included test (`InventoryResourceTest`) tests a scaffold `/hello` endpoint that doesn't exist in the working implementation. This failure is expected and part of the workshop design.
- `labs/catalog-spring-boot` and `labs/gateway-vertx` have no unit tests.
- `npx xo` in `labs/web-nodejs` runs the linter (255 pre-existing style errors in the workshop code).
- The `labs/catalog-go` directory contains an alternative Go-based catalog service for service mesh A/B testing labs (optional).

### Build commands

All Java services: `mvn clean package -DskipTests` from their respective directories (with `JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64`).
