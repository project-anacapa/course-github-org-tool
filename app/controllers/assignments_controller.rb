class AssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_course!
  before_action :set_assignment, only: [:show]

  def index
    @repos = machine_octokit.org_repos(Setting.course)
  end

  # GET /assignments/foo-bar
  # GET /assignments/foo-bar.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      repo_name = "#{Setting.course}/#{params[:id]}"
      @assignment = machine_octokit.repo(repo_name)
      @spec = machine_octokit.contents(repo_name, '.anacapa/assignment_spec.json')
    end

end
