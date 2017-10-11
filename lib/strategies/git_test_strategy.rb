module Strategies
  class GitTestStrategy < Strategies::GitStrategy
    ## A Mock strategy for integration tests

    def initialize(token)
      @token = token
    end

    def add_org_hook(org, config, options={})
      raise NotImplementedError, 'TODO: Implement'
    end

    def emails
      [{
        :email      => "mockuser@example.org",
        :primary    => true,
        :verified   => true,
        :visibility => nil
      }]
    end

    def profile_img_url(uid)
      raise NotImplementedError, 'TODO: Implement'
    end

    def org(name)
      raise NotImplementedError, 'TODO: Implement'
    end

    def org_repos(org)
      raise NotImplementedError, 'TODO: Implement'
    end

    def org_membership(name, params={})
      {:role => 'member', :state => 'active'}
    end

    def org_memberships
      raise NotImplementedError, 'TODO: Implement'
    end

    def repo(repo, params={})
      raise NotImplementedError, 'TODO: Implement'
    end

    def update_org_membership(name, params={})
      'ok'
    end

  end
end
