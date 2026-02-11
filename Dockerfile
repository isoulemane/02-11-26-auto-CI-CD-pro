# Use official Tomcat 10 image
FROM tomcat:10.1.50-jdk17

# Remove default ROOT webapp
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy your WAR directly
COPY webapp.war /usr/local/tomcat/webapps/webapp.war

# Expose Tomcat port
EXPOSE 8080
