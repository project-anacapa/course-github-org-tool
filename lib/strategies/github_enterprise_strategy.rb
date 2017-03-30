module Strategies
  class GitHubEnterpriseStrategy < Strategies::GitHubStrategy

    def initialize(token)
      @url = "https://#{ENV['GIT_PROVIDER_URL']}"
      super
      @token = token
      if @token == nil
        @client = Octokit::Client.new \
                    :client_id => ENV['OMNIAUTH_PROVIDER_KEY'],
                    :client_secret => ENV['OMNIAUTH_PROVIDER_SECRET'],
                    :api_endpoint => "#{@url}/api/v3/"
      else
        @client = Octokit::Client.new \
                    :access_token => @token,
                    :api_endpoint => "#{@url}/api/v3/"
      end
    end

    def profile_img_url(uid)
      return "#{@url}/avatars/u/#{uid}"
    end

  end
end
