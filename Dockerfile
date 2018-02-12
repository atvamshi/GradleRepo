# Start from the Base Image :: https://...
#FROM <website>/<reponame>/<imagename>

# Run the build steps as Root
USER root

#get jre image
FROM openjdk:10-jre

# Create the user 1001
RUN useradd -u 1001 -r -g 0 -d /home  -s /sbin/nologin  -c "Default Application User" default

#creating a logs dir
RUN mkdir -p /logs

#creating app.log file
RUN touch /logs/app.log

#read write execute for everyone
RUN chmod -R 777 /logs

# Make user 1001 the owner of the app log directories
RUN chown -R 1001:0 /logs
RUN chmod -R g+wrx /logs


## NewRelic
#RUN curl -o newrelic.zip '<zip URL>'
#RUN unzip newrelic.zip
#RUN mkdir /newrelic/logs
#RUN rm ./newrelic/newrelic.yml
#RUN curl -o /newrelic/newrelic.yml '<OSE new relic YAM URL>'
#RUN touch /newrelic/logs/newrelic_agent.log
#RUN chmod 777 -R /newrelic
#
## Make user 1001 the owner of the newrelic log directories
#RUN chown -R 1001:0 /newrelic
#RUN chmod -R g+wrx /newrelic



# Copy Application Jar
COPY ./target/app.jar /app.jar

#Comments
EXPOSE 8080

# Switch the user to the non-root user
USER 1001

#Start the Applicaiton and entry point
ENTRYPOINT exec java \
    -Duser.timezone=America/Chicago \
    -Dcom.sun.management.jmxremote \
    -Dcom.sun.management.jmxremote.port=9010 \
    -Dcom.sun.management.jmxremote.local.only=false \
    -Dcom.sun.management.jmxremote.authenticate=false \
    -Dcom.sun.management.jmxremote.ssl=false \
    $JAVA_OPTS -javaagent:/newrelic/newrelic.jar \
    -jar /app.jar