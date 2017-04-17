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
      @assignment = machine_octokit.repo("#{Setting.course}/#{params[:id]}")
    end

end
