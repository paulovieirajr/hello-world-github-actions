# ------------ Build Stage ------------ #
FROM eclipse-temurin:21-jdk-alpine AS build

LABEL maintainer="paulovieirajr"

WORKDIR /app

# Copy only the necessary files to leverage Docker cache
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src ./src

# Build the application
RUN ./mvnw clean package -DskipTests

# ------------ Runtime Stage ------------ #
FROM eclipse-temurin:21-jre-alpine

LABEL maintainer="paulovieirajr"
LABEL io.github.paulovieirajr="paulovieirajr"

# Security: create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy the built jar from the previous stage
COPY --from=build /app/target/hello-world-github-actions.jar app.jar

USER appuser

# Optimized JVM settings
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
