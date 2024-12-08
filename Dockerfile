FROM tomcat:7.0.109-jdk8-openjdk
RUN apt install -y git unzip
RUN git clone --branch AltoroJ-3.2 https://github.com/HCL-TECH-SOFTWARE/AltoroJ.git
RUN wget https://services.gradle.org/distributions/gradle-6.9.4-bin.zip
RUN mkdir /opt/gradle
RUN unzip -d /opt/gradle gradle-6.9.4-bin.zip
RUN cd AltoroJ && /opt/gradle/gradle-6.9.4/bin/gradle build
RUN cp /usr/local/tomcat/AltoroJ/build/libs/altoromutual.war /usr/local/tomcat/webapps
RUN DD_API_KEY=6a0de792d3a4ac8a13d59081bfc113e3 DD_SITE="datadoghq.eu" DD_APM_INSTRUMENTATION_ENABLED=host DD_APM_INSTRUMENTATION_LIBRARIES=java:1,python:2,js:5,dotnet:3 bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)"
EXPOSE 8080 
CMD ["catalina.sh", "run", "-javaagent:/usr/local/tomcat/dd-java-agent.jar"]

#Deloying the Docker file for Altoro Mutual which is also a vulnerable Application for testing purpose  
