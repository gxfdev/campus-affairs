FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY 001-backend/pom.xml .
RUN mvn dependency:go-offline -B
COPY 001-backend/src ./src
RUN mvn package -DskipTests -B

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=builder /app/target/campus-affairs-1.0.0.jar app.jar
COPY 001-backend/src/main/resources/sql/init.sql /app/sql/init.sql

EXPOSE 8088
ENTRYPOINT ["java", "-jar", "app.jar"]
