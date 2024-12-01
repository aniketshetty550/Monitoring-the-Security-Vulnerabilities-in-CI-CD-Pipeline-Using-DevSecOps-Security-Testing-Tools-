FROM tomcat:7.0.109-jdk8-openjdk
RUN apt install -y git unzip
RUN git clone --branch AltoroJ-3.2 https://github.com/HCL-TECH-SOFTWARE/AltoroJ.git
RUN wget https://services.gradle.org/distributions/gradle-6.9.4-bin.zip
RUN mkdir /opt/gradle
RUN unzip -d /opt/gradle gradle-6.9.4-bin.zip
RUN cd AltoroJ && /opt/gradle/gradle-6.9.4/bin/gradle build
RUN cp /usr/local/tomcat/AltoroJ/build/libs/altoromutual.war /usr/local/tomcat/webapps

# Add the Datadog Java agent
COPY /opt/datadog-packages/datadog-apm-library-java/1.43.0/dd-java-agent.jar /opt/datadog/dd-java-agent.jar

# Set the Datadog Java agent in Tomcat
ENV CATALINA_OPTS="-javaagent:/opt/datadog/dd-java-agent.jar -Ddd.iast.enabled=true -Ddd.service=vuln-image -Ddd.env=prod"

EXPOSE 8080 
CMD ["catalina.sh", "run"]

#Deloying the Docker file for Altoro Mutual which is also a vulnerable Application for testing purpose      