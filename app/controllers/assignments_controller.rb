class AssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_course!

  def index
    @repos = machine_octokit.org_repos(Setting.course)

    # todo: get all assignment repos, i.e. repos with pattern assignment-*
    # todo: get all student code repos, i.e. repos with pattern <assignment_name>-(<student_name>-)*<student_name>
  end

  private

end
