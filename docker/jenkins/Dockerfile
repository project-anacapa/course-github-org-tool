FROM jenkins:alpine

USER root
RUN mkdir /jenkins
RUN chown -R jenkins:jenkins /jenkins
ENV JENKINS_HOME="/jenkins"

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

USER jenkins:jenkins

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy
