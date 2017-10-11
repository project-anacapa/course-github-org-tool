module Strategies
  class GitLabStrategy < Strategies::GitStrategy

    def initialize(token)
      raise NotImplementedError, 'TODO: Implement'
    end

    def add_org_hook(org, config, options={})
      raise NotImplementedError, 'TODO: Implement'
    end

    def emails
      raise NotImplementedError, 'TODO: Implement'
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
