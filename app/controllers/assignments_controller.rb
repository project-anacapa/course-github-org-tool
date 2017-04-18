class AssignmentsController < ApplicationController
  before_action :authenticate_user!
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
      @assignment = machine_octokit.repo("#{course_org_name}/#{params[:id]}")
    end

end
