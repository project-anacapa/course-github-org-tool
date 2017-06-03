class JenkinsStatusController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:index]

  def index
    GenerateGradeJob.perform_later(params.as_json)
    head(:ok)
  end
end
