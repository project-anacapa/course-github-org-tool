module OctokitHelper
  def anon_octokit
    Strategies::GitStrategy.get_instance(nil)
  end

  def machine_octokit
    Strategies::GitStrategy.get_instance(ENV['MACHINE_USER_KEY'])
  end

  def ensure_repo(client, org, repo_name, private=true, auto_init=false)
    full_name = "#{org}/#{repo_name}"
    repo = machine_octokit.repo(full_name)
    existed = ! repo.blank?

    if ! existed
      logger.warn "Creating assignment repo #{full_name}"
      repo = client.create_repository(repo_name, {
          :organization => org,
          :private => private,
          :auto_init => auto_init
      })
    elsif private
      logger.warn "Repo #{full_name} already exists! Ensuring proper settings"
      client.set_private(repo)
    end

    repo
  end
end
