module Strategies
  class GitStrategy

    def initialize(token)
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def self.get_instance(token)
      case ENV['OMNIAUTH_STRATEGY']
      when "github"
        return GitHubStrategy.new(token)
      when "github_enterprise"
        return GitHubEnterpriseStrategy.new(token)
      when "gitlab"
        return GitLabStrategy.new(token)
      else # default to github?
        return GitHubStrategy.new(token)
      end
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

    def org_membership(name, params={})
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def org_memberships
      raise NotImplementedError, 'Use a Specific Implementation'
    end

    def update_org_membership(name, params={})
      raise NotImplementedError, 'Use a Specific Implementation'
    end

  end
end
