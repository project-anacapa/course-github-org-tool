class JenkinsStatusController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:index]

  def index
    GenerateGradeJob.perform_later(JSON.parse(request.body.read))
    head(:ok)
  end
end
