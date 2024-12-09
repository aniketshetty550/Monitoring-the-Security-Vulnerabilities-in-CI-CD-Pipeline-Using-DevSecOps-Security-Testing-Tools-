FROM tomcat:7.0.109-jdk8-openjdk

# Install required tools
RUN apt-get update && apt-get install -y git unzip wget curl ca-certificates

# Clone the AltoroJ application
RUN git clone --branch AltoroJ-3.2 https://github.com/HCL-TECH-SOFTWARE/AltoroJ.git

# Install Gradle
RUN wget https://services.gradle.org/distributions/gradle-6.9.4-bin.zip
RUN mkdir /opt/gradle
RUN unzip -d /opt/gradle gradle-6.9.4-bin.zip

# Build the application using Gradle
RUN cd AltoroJ && /opt/gradle/gradle-6.9.4/bin/gradle build

# Deploy the WAR file to Tomcat
RUN cp AltoroJ/build/libs/altoromutual.war /usr/local/tomcat/webapps/

# Add Datadog Serverless Init and Java Tracer
COPY --from=datadog/serverless-init:1 /datadog-init /app/datadog-init
ADD 'https://dtdg.co/latest-java-tracer' /dd_tracer/java/dd-java-agent.jar

# Unified Service Tagging Environment Variables
ENV DD_SERVICE=altoro-mutual
ENV DD_API_KEY=97980b005d2da6e9581f0ceb2d1621d5
ENV DD_ENV=prod
ENV DD_VERSION=1.0.0
ENV DD_PROFILING_ENABLED=true
ENV DD_LOGS_INJECTION=true
ENV DD_APPSEC_ENABLED=true
ENV DD_IAST_ENABLED=true
ENV DD_APPSEC_SCA_ENABLED=true
ENV DD_SITE=datadoghq.eu

# Git repository and commit information
ARG DD_GIT_REPOSITORY_URL
ARG DD_GIT_COMMIT_SHA
ENV DD_GIT_REPOSITORY_URL=${DD_GIT_REPOSITORY_URL}
ENV DD_GIT_COMMIT_SHA=${DD_GIT_COMMIT_SHA}

# Unified Service Tagging Labels
LABEL eu.datadoghq.tags.service="altoro-mutual"
LABEL eu.datadoghq.tags.env="prod"
LABEL eu.datadoghq.tags.version="1.0.0"

# Expose port 8080
EXPOSE 8080

# Set Datadog Serverless Init as Entrypoint and start Tomcat
ENTRYPOINT ["/app/datadog-init"]
CMD ["catalina.sh", "run", \
     "-javaagent:/dd_tracer/java/dd-java-agent.jar", \
     "-Ddd.service=${DD_SERVICE}", \
     "-Ddd.env=${DD_ENV}", \
     "-Ddd.version=${DD_VERSION}", \
     "-Ddd.logs.injection=${DD_LOGS_INJECTION}", \
     "-Ddd.profiling.enabled=${DD_PROFILING_ENABLED}", \
     "-Ddd.appsec.enabled=${DD_APPSEC_ENABLED}", \
     "-Ddd.iast.enabled=${DD_IAST_ENABLED}", \
     "-Ddd.appsec.sca.enabled=${DD_APPSEC_SCA_ENABLED}", \
     "-Ddd.git.commit.sha=${DD_GIT_COMMIT_SHA}", \
     "-Ddd.git.repository_url=${DD_GIT_REPOSITORY_URL}"]
