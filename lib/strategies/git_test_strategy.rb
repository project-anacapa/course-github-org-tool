module Strategies
  class GitTestStrategy < Strategies::GitStrategy
    ## A Mock strategy for integration tests

    def initialize(token)
      @token = token
    end

    def emails
      ['mockuser@example.org']
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
      raise NotImplementedError, 'TODO: Implement'
    end

    def org_memberships
      raise NotImplementedError, 'TODO: Implement'
    end

    def repo(repo, params={})
      raise NotImplementedError, 'TODO: Implement'
    end

    def update_org_membership(name, params={})
      raise NotImplementedError, 'TODO: Implement'
    end

  end
end
