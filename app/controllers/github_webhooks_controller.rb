class GithubWebhooksController < ApplicationController
  include GithubWebhook::Processor
  skip_before_action :verify_authenticity_token, only: [:create]

  def github_member(payload)
    # TODO
    head(:ok)
  end

  def github_public(payload)
    # TODO
    head(:ok)
  end

  def github_push(payload)
    # TODO
    head(:ok)
  end

  def github_repository(payload)
    # TODO
    head(:ok)
  end

  def webhook_secret(payload)
    ENV['WEBHOOK_SECRET']
  end
end
