class HandlePushJob < ApplicationJob
  queue_as :default

  def perform(payload)
    # Do something later
    logger.warn "Hello World from HandlePushJob!"
    logger.warn payload
  end
end
