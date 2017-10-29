import javaposse.jobdsl.plugin.GlobalJobDslSecurityConfiguration
import jenkins.model.*
import hudson.security.*

/*
 * Configure JobDslSecurityConfiguration to not require script security
 * Otherwise JobDSL requires every new script to individually be approved
 * This is an incredibly annoying unwanted behavior
 */ 

System.out.println("Jenkins configuring JobDslSecurityConfiguration")

GlobalJobDslSecurityConfiguration config
config = Jenkins.instance.getDescriptorByType(GlobalJobDslSecurityConfiguration)
config.useScriptSecurity = false
