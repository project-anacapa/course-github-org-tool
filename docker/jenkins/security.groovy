#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule

System.out.println("Jenkins configuring up users and passwords");

def instance = Jenkins.getInstance()

// setup the admin user account
def user = new File("/run/secrets/jenkins-user").text.trim()
def pass = new File("/run/secrets/jenkins-pass").text.trim()

System.out.println("\tAdmin user in: /run/secrets/jenkins-user")
System.out.println("\tAdmin pass in: /run/secrets/jenkins-pass")

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(user, pass)
instance.setSecurityRealm(hudsonRealm)

// setup the login strategy
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false) // disable anonymous users from logging in
instance.setAuthorizationStrategy(strategy)

// disallow CSRF attacks
instance.setCrumbIssuer(new hudson.security.csrf.DefaultCrumbIssuer(true))

instance.save()

// dissable CLI access to the Jenkins installation
jenkins.model.Jenkins.instance.getDescriptor("jenkins.CLI").get().setEnabled(false)

// dissallow slave to master access control https://wiki.jenkins.io/display/JENKINS/Slave+To+Master+Access+Control
Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class)
  .setMasterKillSwitch(false)

Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)

Jenkins.instance.save()

