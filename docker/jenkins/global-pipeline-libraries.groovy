import org.jenkinsci.plugins.workflow.libs.GlobalLibraries;
import org.jenkinsci.plugins.workflow.libs.SCMSourceRetriever;
import org.jenkinsci.plugins.workflow.libs.LibraryConfiguration;
import org.jenkinsci.plugins.workflow.libs.*;
import jenkins.plugins.git.GitSCMSource;

// automatically sets up the anacapa-jenkins-lib global pipeline library
LibraryConfiguration libraryConfiguration =
  new LibraryConfiguration("anacapa-jenkins-lib",
    new SCMSourceRetriever(
      new GitSCMSource(null, "https://github.com/project-anacapa/anacapa-jenkins-lib.git", "", "*", "", true)));

libraryConfiguration.setDefaultVersion("master");
libraryConfiguration.setImplicit(true);

// set the global libraries to contain our anacapa-jenkins-lib global library
GlobalLibraries.get().setLibraries(Collections.singletonList(libraryConfiguration));
