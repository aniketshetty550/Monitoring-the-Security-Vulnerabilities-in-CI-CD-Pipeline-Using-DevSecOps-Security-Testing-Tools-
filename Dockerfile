FROM tomcat:7.0.109-jdk8-openjdk
COPY --from=datadog/serverless-init:1 /datadog-init /app/datadog-init
WORKDIR /usr/local/tomcat
RUN apt-get update && apt-get install -y git unzip curl
RUN git clone --branch AltoroJ-3.2 https://github.com/HCL-TECH-SOFTWARE/AltoroJ.git
RUN ls -l /usr/local/tomcat
RUN wget https://services.gradle.org/distributions/gradle-6.9.4-bin.zip
RUN mkdir /opt/gradle
RUN unzip -d /opt/gradle gradle-6.9.4-bin.zip
RUN cd /usr/local/tomcat/AltoroJ && /opt/gradle/gradle-6.9.4/bin/gradle build
RUN ls -l /usr/local/tomcat/AltoroJ/build/libs
RUN cp /usr/local/tomcat/AltoroJ/build/libs/altoromutual.war /usr/local/tomcat/webapps/
ADD 'https://dtdg.co/latest-java-tracer' /dd_tracer/java/dd-java-agent.jar
ENV DD_SERVICE=datadog-demo-run-java
ENV DD_ENV=prod
ENV DD_VERSION=1
ENV DD_APM_ENABLED=true
ENV DD_SITE="datadoghq.com"
ENV DD_API_KEY=97980b005d2da6e9581f0ceb2d1621d5
ENV CATALINA_OPTS="-javaagent:/dd_tracer/java/dd-java-agent.jar \
    -Ddd.iast.enabled=true \
    -Ddd.service=altoro-vuln-app \
    -Ddd.env=prod \
    -Ddd.trace.debug=true \
    -Ddd.tags=env:staging,app:altoro"

# Expose Tomcat port
EXPOSE 8080

# Use Datadog serverless-init as the entrypoint
ENTRYPOINT ["/app/datadog-init"]

# Start Tomcat
CMD ["catalina.sh", "run"]
