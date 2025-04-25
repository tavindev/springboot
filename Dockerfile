# Build stage
FROM eclipse-temurin:24-jdk-jammy as builder

# Set working directory
WORKDIR /app

# Copy Maven wrapper and pom.xml
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Copy source code
COPY src src

# Build the application
RUN chmod +x mvnw
RUN ./mvnw clean package -DskipTests

# Run stage
FROM eclipse-temurin:24-jre-jammy

# Create a non-root user
RUN groupadd -r spring && useradd -r -g spring spring
USER spring

# Set working directory
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Set JVM options
ENV JAVA_OPTS="-Xms512m -Xmx512m -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Expose the port the app runs on
EXPOSE 8080

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"] 