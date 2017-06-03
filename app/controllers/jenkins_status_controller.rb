class JenkinsStatusController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:index]

  def index
    puts request
    head(:ok)
  end
end
