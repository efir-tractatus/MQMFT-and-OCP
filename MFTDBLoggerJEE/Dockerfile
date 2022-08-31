FROM icr.io/appcafe/websphere-liberty:latest

USER 1001
COPY --chown=1001:0 --chmod-0775 server.xml /config/
COPY --chown=1001:0 --chmod-0775 dropins /config/dropins
COPY --chown=1001:0 --chmod-0775 key.p12 /config/resources/security/
ADD  --chown=1001:0 --chmod-0775 https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc8/21.7.0.0/ojdbc8-21.7.0.0.jar /config/lib/
ADD  --chown=1001:0 --chmod-0775 https://repo1.maven.org/maven2/com/ibm/mq/wmq.jmsra/9.3.0.0/wmq.jmsra-9.3.0.0.rar /config/lib/wmq.jmsra.rar
