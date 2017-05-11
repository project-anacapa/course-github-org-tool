module Strategies
  class GitStrategy

    def initialize(token)
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def self.get_instance(token)
      # if in test environment, return mocked strategy
      if ENV['RAILS_ENV'] == "test"
        return GitTestStrategy.new(token)
      end

      # otherwise check the omniauth_strategy environment variable
      case ENV['OMNIAUTH_STRATEGY']
      when 'github'
        return GitHubStrategy.new(token)
      when 'github_enterprise'
        return GitHubEnterpriseStrategy.new(token)
      when 'gitlab'
        return GitLabStrategy.new(token)
      else # default to github?
        return GitHubStrategy.new(token)
      end
    end

    def is_valid
      true
    end

    def add_collaborator(repo, collaborator, options = {})
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def add_org_hook(org, config, options={})
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def collaborators(repo, options = {})
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def collaborator?(repo, collaborator, options = {})
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def contents(repo, options={})
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def create_contents(repo, path, message, content=nil, options={})
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def create_repository(name, options={})
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def emails
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def profile_img_url(uid)
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def org(name)
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def org_repos(org)
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def org_membership(name, params={})
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def org_memberships
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def repo(repo, params={})
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def update_org_membership(name, params={})
      raise NotImplementedError, 'Use a Specific Implementation'
    end

  end
end
