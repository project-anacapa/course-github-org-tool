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

    # TODO: REMOVE WHEN NOT IN DEVELOPMENT PHASE!
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

    def collaborator?(repo, collaborator, options = {})
      @client.collaborator?(repo, collaborator, options=options)
    end

    def contents(repo, path, ref="master")
      begin
        @client.contents(repo, :path => path, :ref => ref)
      rescue
        nil
      end
    end
9
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
      begin
        @client.repo(repo, params)
      rescue
        nil
      end
    end

    def update_org_membership(name, params={})
      @client.update_org_membership(name, params)
    end

  end
end
