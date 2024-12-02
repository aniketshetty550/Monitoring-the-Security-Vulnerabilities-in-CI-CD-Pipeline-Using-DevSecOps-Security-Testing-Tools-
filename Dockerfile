FROM tomcat:7.0.109-jdk8-openjdk
COPY --from=datadog/serverless-init:1 /datadog-init /app/datadog-init
WORKDIR /app
COPY . /app
ADD 'https://dtdg.co/latest-java-tracer' /dd_tracer/java/dd-java-agent.jar
ENV DD_SERVICE=datadog-demo-run-java
ENV DD_ENV=prod
ENV DD_VERSION=1
ENV DD_APM_ENABLED=true
ENV DD_APM_NON_LOCAL_TRAFFIC=true
ENV DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true
ENV DD_TRACE_ENABLED=true
ENV DD_SITE="datadoghq.com"
ENV DD_API_KEY=97980b005d2da6e9581f0ceb2d1621d5
ENV DD_TRACE_PROPAGATION_STYLE='datadog'
ENV CATALINA_OPTS="-javaagent:/dd_tracer/java/dd-java-agent.jar \
    -Ddd.iast.enabled=true \
    -Ddd.service=altoro-vuln-app \
    -Ddd.env=prod \
    -Ddd.trace.debug=true \
    -Ddd.tags=env:staging,app:altoro"
RUN apt-get update && apt-get install -y git unzip curl
RUN git clone --branch AltoroJ-3.2 https://github.com/HCL-TECH-SOFTWARE/AltoroJ.git
RUN wget https://services.gradle.org/distributions/gradle-6.9.4-bin.zip
RUN mkdir /opt/gradle
RUN unzip -d /opt/gradle gradle-6.9.4-bin.zip
RUN cd AltoroJ && /opt/gradle/gradle-6.9.4/bin/gradle build
RUN cp /app/AltoroJ/build/libs/altoromutual.war /usr/local/tomcat/webapps

RUN DD_IAST_ENABLED=true DD_APM_INSTRUMENTATION_ENABLED=docker DD_NO_AGENT_INSTALL=true \
    bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)"
EXPOSE 8080

# Use Datadog serverless-init as the entrypoint
ENTRYPOINT ["/app/datadog-init"]

CMD ["catalina.sh", "run"]