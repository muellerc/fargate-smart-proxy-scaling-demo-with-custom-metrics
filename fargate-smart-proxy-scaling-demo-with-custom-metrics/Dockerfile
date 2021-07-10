FROM amazoncorretto:11

# add our custom wiremock mapping and file
COPY target/fargate-smart-proxy-scaling-demo-with-custom-metrics-0.0.1-SNAPSHOT.jar app.jar

ENTRYPOINT ["java"]
CMD ["-jar", "app.jar"]