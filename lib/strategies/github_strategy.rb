module Strategies
  class GitHubStrategy < Strategies::GitStrategy

    def initialize(token)
      @token = token
      if @token == nil
        @client = Octokit::Client.new \
                    :client_id => ENV['OMNIAUTH_PROVIDER_KEY'],
                    :client_secret => ENV['OMNIAUTH_PROVIDER_SECRET']
      else
        @client = Octokit::Client.new \
                    :access_token => @token
      end
    end

    def get_client
      @client
    end

    def is_valid
      begin
        _ = @client.user  # this should work if the token is valid
        return true
      rescue Exception => e
        puts e
        return false
      end
    end

    def add_org_hook(org, config, options={})
      raise "URL must be provided" unless config.key?(:url)
      dest_url = config[:url]

      existing_hook = @client.org_hooks(org).select { |hook| hook[:config][:url].eql?(dest_url) }
      if existing_hook.empty?
        @client.create_org_hook(org, config, options)
      else
        existing_hook = existing_hook[0]
        @client.edit_org_hook(org, existing_hook[:id], config, options)
      end
    end

    def emails
      @client.emails
    end

    def profile_img_url(uid)
      "https://avatars2.githubusercontent.com/u/#{uid}"
    end

    def org(name)
      @client.org(name)
    end

    def org_repos(org)
      @client.org_repos(org)
    end

    def org_membership(name, params={})
      @client.org_membership(name, params)
    end

    def org_memberships
      @client.org_memberships
    end

    def repo(repo, params={})
      @client.repo(repo, params)
    end

    def update_org_membership(name, params={})
      @client.update_org_membership(name, params)
    end

  end
end
