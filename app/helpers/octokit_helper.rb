module OctokitHelper
  def anon_octokit
    Strategies::GitStrategy.get_instance(nil)
  end

  def machine_octokit
    Strategies::GitStrategy.get_instance(ENV['MACHINE_USER_KEY'])
  end
end
