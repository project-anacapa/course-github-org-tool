class AssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action { require_feature! 'anacapa_repos' }
  before_action :set_assignment, only: [:show]

  def index
    @repos = machine_octokit.org_repos(course_org_name)
  end

  # GET /assignments/foo-bar
  # GET /assignments/foo-bar.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      repo_name = "#{course_org_name}/#{params[:id]}"
      @assignment = machine_octokit.repo(repo_name)
      begin
        @spec = machine_octokit.contents(repo_name, '.anacapa/assignment_spec.json')
        @spec = JSON.parse(Base64.decode64(@spec.content))
      rescue Exception => e
        @spec = {}
        logger.warn e
      end
    end

end
