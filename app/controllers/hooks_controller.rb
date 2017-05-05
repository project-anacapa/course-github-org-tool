class HooksController < ApplicationController
  def github

    # The web-hook doesn't require a response but let's make sure
    # we don't send anything
    render :nothing => true
  end
end
