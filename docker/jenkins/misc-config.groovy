import jenkins.model.JenkinsLocationConfiguration

println("Jenkins misc configuration")


println("\t- setting jenkins location")
jlc = JenkinsLocationConfiguration.get()
jlc.setUrl("http://jenkins:8080/") 
jlc.save()
