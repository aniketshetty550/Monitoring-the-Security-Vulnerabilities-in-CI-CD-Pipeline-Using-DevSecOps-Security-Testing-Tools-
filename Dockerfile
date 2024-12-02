FROM tomcat:7.0.109-jdk8-openjdk
RUN apt install -y git unzip
RUN git clone --branch AltoroJ-3.2 https://github.com/HCL-TECH-SOFTWARE/AltoroJ.git
RUN wget https://services.gradle.org/distributions/gradle-6.9.4-bin.zip
RUN mkdir /opt/gradle
RUN unzip -d /opt/gradle gradle-6.9.4-bin.zip
RUN cd AltoroJ && /opt/gradle/gradle-6.9.4/bin/gradle build
RUN cp /usr/local/tomcat/AltoroJ/build/libs/altoromutual.war /usr/local/tomcat/webapps

# Install Datadog agent and enable IAST (Code Security)
RUN DD_IAST_ENABLED=true DD_APM_INSTRUMENTATION_ENABLED=docker DD_NO_AGENT_INSTALL=true bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)"

# Set the Datadog API Key and Site for the agent
ENV DD_API_KEY=97980b005d2da6e9581f0ceb2d1621d5
ENV DD_SITE="datadoghq.eu"

# Add the Datadog Java agent
ADD https://github.com/DataDog/dd-trace-java/releases/latest/download/dd-java-agent.jar /opt/datadog/dd-java-agent.jar

# Set the Datadog Java agent in Tomcat
ENV CATALINA_OPTS="-javaagent:/opt/datadog/dd-java-agent.jar -Ddd.iast.enabled=true -Ddd.service=vuln-image -Ddd.env=prod -Ddd.trace.debug=true -Ddd.tags=env:staging,app:altoro" 

# Set additional environment variables for Datadog
ENV DD_ENV=prod
ENV DD_APM_ENABLED=true
ENV DD_APM_NON_LOCAL_TRAFFIC=true
ENV DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true
ENV DD_APM_RECEIVER_SOCKET=/opt/datadog/apm/inject/run/apm.socket
ENV DD_DOGSTATSD_SOCKET=/opt/datadog/apm/inject/run/dsd.socket

EXPOSE 8080 
CMD ["catalina.sh", "run"]

#Deloying the Docker file for Altoro Mutual which is also a vulnerable Application for testing purpose      