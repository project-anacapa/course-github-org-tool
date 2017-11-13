FROM jenkins:alpine

USER root
RUN mkdir /jenkins
RUN chown -R jenkins:jenkins /jenkins
ENV JENKINS_HOME="/jenkins"

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

USER jenkins:jenkins

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
COPY anacapa-jenkins-lib.jenkinsjob.xml /anacapa-jenkins-lib.jenkinsjob.xml 
COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy
COPY global-pipeline-libraries.groovy /usr/share/jenkins/ref/init.groovy.d/global-pipeline-libraries.groovy
COPY dsl-setup.groovy /usr/share/jenkins/ref/init.groovy.d/dsl-setup.groovy 
COPY jenkins-worker-setup.groovy /usr/share/jenkins/ref/init.groovy.d/jenkins-worker-setup.groovy 
COPY misc-config.groovy /usr/share/jenkins/ref/init.groovy.d/misc-config.groovy 