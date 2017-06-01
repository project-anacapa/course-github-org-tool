AnacapaJenkinsLib.configure(YAML.load_file("./jenkins.yml"))

class HandlePushJob < ApplicationJob
  queue_as :default
  include AssignmentsHelper

  def perform(push)
    assign_repos = assignment_repos

    repo = push['repository']['name']
    url = push['repository']['url']
    commit = push['head_commit']['id']

    logger.warn "Received push event webhook for repo: #{repo} (commit #{commit})"
    logger.warn "Repo url: #{url}"
    logger.warn "is assignment repo? #{is_assignment? repo}"
    logger.warn "is student repo? #{is_student_repo? assign_repos, repo}"
    logger.warn JSON.pretty_generate(push)

    if is_assignment? repo then
      assignment = AnacapaJenkinsLib::Assignment.new(
        :gitProviderDomain => ENV['GIT_PROVIDER_URL'],
        :courseOrg => ENV['COURSE_ORGANIZATION'],
        :credentialsId => ENV['JENKINS_MACHINE_USER_CREDENTIALS_ID'],
        :labName => repo[('assignment-'.length) .. -1]
      )

      begin
        assignment.checkJenkinsState
        build = assignment.jobInstructor.rebuild
      rescue Exception => e
        logger.error("Error processing webhook: #{e.message}")
      end

    elsif is_student_repo? assign_repos, repo then
      assign_repo = student_repo_get_assignment(assign_repos, repo)

      assignment = AnacapaJenkinsLib::Assignment.new(
        :gitProviderDomain => ENV['GIT_PROVIDER_URL'],
        :courseOrg => ENV['COURSE_ORGANIZATION'],
        :credentialsId => ENV['JENKINS_MACHINE_USER_CREDENTIALS_ID'],
        :labName => assign_repo.name[('assignment-'.length) .. -1]
      )

      begin
        assignment.checkJenkinsState
        build = assignment.jobGrader.rebuild({
          student_repo: assign_repo,
          commit: push['head_commit']['id']
        })
      rescue Exception => e
        logger.error("Error processing webhook: #{e.message}")
      end
    else
      logger.warn "Push notification corresponds to neither a student repo nor an instructor repo"
    end
  end

end
