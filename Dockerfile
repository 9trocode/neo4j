# Dockerfile

# 1. Use an official OpenJDK image as the build environment
FROM eclipse-temurin:17-jdk AS build

# 2. Set workdir and copy source code
WORKDIR /neo4j
COPY . .

# 3. Build Neo4j using Maven
RUN ./mvnw clean install -DskipTests

# 4. Use a smaller JRE image for the runtime
FROM eclipse-temurin:17-jre

# 5. Create a user for security
RUN useradd -ms /bin/bash neo4j

# 6. Copy the built Neo4j server from the build stage
COPY --from=build /neo4j/community/packaging/standalone/target/neo4j-community-*-unix.tar.gz /tmp/

# 7. Extract and move to /neo4j
RUN mkdir /neo4j && \
    tar -xzf /tmp/neo4j-community-*-unix.tar.gz -C /neo4j --strip-components=1 && \
    rm /tmp/neo4j-community-*-unix.tar.gz && \
    chown -R neo4j:neo4j /neo4j

# 8. Expose ports
EXPOSE 7474 7687

# 9. Set environment variables (change password as needed)
ENV NEO4J_AUTH=neo4j/testpassword

# 10. Set data and logs as volumes
VOLUME ["/neo4j/data", "/neo4j/logs"]

# 11. Switch to neo4j user
USER neo4j

# 12. Start Neo4j
WORKDIR /neo4j
ENTRYPOINT ["bin/neo4j"]
CMD ["console"]
