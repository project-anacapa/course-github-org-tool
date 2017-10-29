module Strategies
  class GitLabStrategy < Strategies::GitStrategy

    def initialize(token)
      raise NotImplementedError, 'TODO: Implement'
    end

    def add_collaborator(repo, collaborator, options = {})
      raise NotImplementedError, 'TODO: Implement'
    end

    def add_org_hook(org, config, options={})
      raise NotImplementedError, 'TODO: Implement'
    end

    def collaborators(repo, options = {})
      raise NotImplementedError, 'TODO: Implement'
    end

    def collaborator?(repo, collaborator, options = {})
      raise NotImplementedError, 'TODO: Implement'
    end

    def contents(repo, options={})
      raise NotImplementedError, 'TODO: Implement'
    end

    def create_contents(repo, path, message, content=nil, options={})
      raise NotImplementedError, 'TODO: Implement'
    end

    def create_repository(name, options={})
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

    def set_private(repo)
      raise NotImplementedError, 'TODO: Implement'
    end

    def update_contents(repo, path, message, sha, content=nil, options={})
      raise NotImplementedError, 'TODO: Implement'
    end

    def update_org_membership(name, params={})
      raise NotImplementedError, 'TODO: Implement'
    end

  end
end
