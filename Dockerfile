
FROM openjdk:17-jdk-slim-buster

WORKDIR /app

COPY target/app.jar app.jar


EXPOSE 8080


ENTRYPOINT ["java", "-jar", "app.jar"]