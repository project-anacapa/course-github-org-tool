import org.jenkinsci.plugins.workflow.libs.GlobalLibraries;
import org.jenkinsci.plugins.workflow.libs.SCMSourceRetriever;
import org.jenkinsci.plugins.workflow.libs.LibraryConfiguration;
import org.jenkinsci.plugins.workflow.libs.*;
import hudson.model.*;
import jenkins.model.*;
import jenkins.plugins.git.GitSCMSource;

System.out.println("Jenkins Configuring anacapa-jenkins-lib global pipeline library.")

// automatically sets up the anacapa-jenkins-lib global pipeline library
LibraryConfiguration libraryConfiguration =
  new LibraryConfiguration("anacapa-jenkins-lib",
    new SCMSourceRetriever(
      new GitSCMSource(null, "https://github.com/project-anacapa/anacapa-jenkins-lib.git", "", "*", "", true)));

libraryConfiguration.setDefaultVersion("master");
libraryConfiguration.setImplicit(true);

GlobalLibraries.get().setLibraries(Collections.singletonList(libraryConfiguration));

println("Jenkins Configuring anacapa-jenkins-lib bootstrap job & running it.\n")

def instance = Jenkins.getInstance()

String jobName = "anacapa-jenkins-lib"
String jobXML = new File("/anacapa-jenkins-lib.jenkinsjob.xml").text

def xmlStream = new ByteArrayInputStream( jobXML.getBytes() )
Jenkins.instance.createProjectFromXML(jobName, xmlStream)

// automatically schedule the execution of that job
println("Scheduling the execution of the bootstrap job.")
def job = hudson.model.Hudson.instance.getJob("anacapa-jenkins-lib")
def scheduledJob = hudson.model.Hudson.instance.queue.schedule(job, 10)
def urlFuture = scheduledJob.getFuture().waitForStart().getUrl()
println("Scheduled bootstrap job, url: " + urlFuture)