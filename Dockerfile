FROM tomcat:7.0.109-jdk8-openjdk

# Install required tools
RUN apt-get update && apt-get install -y git unzip wget

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

# Download the Datadog Java Agent
ADD 'https://dtdg.co/latest-java-tracer' /dd-java-agent.jar

# Expose port 8080
EXPOSE 8080

# Start Tomcat with Datadog Java Agent
CMD ["catalina.sh", "run", \
     "-javaagent:/dd-java-agent.jar", \
     "-Ddd.service=altoro-mutual", \
     "-Ddd.env=prod", \
     "-Ddd.version=1.0.0", \
     "-Ddd.logs.injection=true", \
     "-Ddd.profiling.enabled=true", \
     "-Ddd.appsec.enabled=true", \
     "-Ddd.iast.enabled=true", \
     "-Ddd.git.commit.sha=${DD_GIT_COMMIT_SHA}", \
     "-Ddd.git.repository_url=${DD_GIT_REPOSITORY_URL}"]
