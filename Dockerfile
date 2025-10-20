# Multi-stage build để optimize image size
FROM maven:3.9.9-openjdk-21 AS build

# Set working directory
WORKDIR /app

# Copy pom.xml và tải dependencies trước để cache layer
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code và build application
COPY src ./src
RUN mvn clean package -DskipTests -B

# Runtime stage với OpenJDK slim image
FROM openjdk:21-jdk-slim

# Install cần thiết packages và tạo user non-root
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy JAR file từ build stage
COPY --from=build /app/target/OneShop-*.jar app.jar

# Tạo thư mục upload và set permissions
RUN mkdir -p /app/upload/images /app/upload/brands /app/upload/providers \
    && chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Expose port
EXPOSE 8080

# Set production profile và JVM options
ENV SPRING_PROFILES_ACTIVE=production
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:+UseContainerSupport"

# Run application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
