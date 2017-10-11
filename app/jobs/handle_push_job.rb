class HandlePushJob < ApplicationJob
  queue_as :default
  include AssignmentsHelper

  def perform(push)
    # Do something later
    repo = push['repository']['name']
    url = push['repository']['url']
    commit = push['head_commit']['id']
    logger.warn "Received push event webhook for repo: #{repo} (commit #{commit})"
    logger.warn "Repo url: #{url}"
    logger.warn "is assignment repo? #{is_assignment? repo}"
    logger.warn "is student repo? #{is_student_repo? assignment_names, repo}"
    logger.warn push
  end
end
