class AssignmentsController < ApplicationController
  include AssignmentsHelper
  before_action :authenticate_user!
  before_action { require_feature! 'anacapa_repos' }
  before_action :set_assignment, only: [:show, :checkout]

  # GET /assignments
  def index
    @repos = machine_octokit.org_repos(course_org_name)
  end

  # GET /assignments/:id
  # GET /assignments/:id.json
  def show
  end

  # POST /assignments/:id/checkout
  def checkout
    CheckoutAssignmentJob.perform_later(params[:id], params[:student])
    redirect_to assignment_path params[:id]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      repo_name = "#{course_org_name}/#{params[:id]}"
      @assignment = machine_octokit.repo(repo_name)
      @spec = get_assignment_spec(repo_name)
    end

end
