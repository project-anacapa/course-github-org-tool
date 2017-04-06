class AssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_instructor!

  def index
  end

  private

end
