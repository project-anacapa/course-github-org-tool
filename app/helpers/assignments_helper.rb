module AssignmentsHelper
  include OctokitHelper

  def get_assignment_spec(repo_name)
    begin
      spec = machine_octokit.contents(repo_name, :path => '.anacapa/assignment_spec.json')
      spec = JSON.parse(Base64.decode64(spec.content))
    rescue Exception => e
      logger.warn e
      spec = {}
    end
    spec
  end

  def is_assignment?(repo_name)
    (repo_name =~ /^assignment-([\w\d\-_]+)$/i) == 0
  end

  def is_student_repo?(assignments, repo_name)
    assignments.any? do |a|
      if a.is_a? String
        name = a.split("assignment-").last
      else # a repo object
        name = a.name.split("assignment-").last
      end
      repo_name =~ /^#{name}-([\w\d\-_]+)$/i
    end
  end

  def student_repo_get_assignment(assignments, repo_name)
    assignments.each do |a|
      if a.is_a? String
        name = a.split("assignment-").last
      else # a repo object
        name = a.name.split("assignment-").last
      end
      if repo_name =~ /^#{name}-([\w\d\-_]+)$/i
        return a, repo_name.split("#{name}-").last
      end
    end

    nil
  end

  def get_students(repo)
    usernames = machine_octokit.collaborators(repo).map { |r| r.login }
    usernames.select { |user| repo.include? user }
  end

  # @param [array] repos
  def assignment_repos(repos=nil, check_ready=false)
    repos ||= machine_octokit.org_repos(ENV['COURSE_ORGANIZATION'])
    assignments = repos.select { |repo| is_assignment? repo.name }

    if ! check_ready
      assignments
    else
      assignments.select do |repo|
        get_assignment_spec(repo.full_name)['ready']
      end
    end

  end

  def assignment_names(repos=nil)
    repos ||= machine_octokit.org_repos(ENV['COURSE_ORGANIZATION'])
    sub_index = 'assignment-'.length
    # get the list of valid assignment names (omitting the starting 'assignment-')
    assignment_repos(repos).map {|repo| repo.name[sub_index..-1]}
  end

  # @param [array] repos
  def student_repos(repos=nil, student=nil, assignment=nil)
    course = ENV['COURSE_ORGANIZATION']
    repos ||= machine_octokit.org_repos(course)
    sub_index = 'assignment-'.length
    # get the list of valid assignment names (omitting the starting 'assignment-')
    assignments = assignment_repos(repos).map {|repo| repo.name[sub_index..-1]}

    # get only repos with names that correspond to valid and known assignments
    ret = repos.select { |repo| is_student_repo? assignments, repo.name }

    unless student.blank?
      ret = ret.select { |repo| machine_octokit.collaborator? "#{course}/#{repo.name}", student }
    end

    unless assignment.blank?
      assignment_name = assignment.split("assignment-").last
      ret = ret.select { |repo| repo.name.include? assignment_name }
    end

    ret
  end

  def unrelated_repos(repos=nil)
    repos ||= machine_octokit.org_repos(ENV['COURSE_ORGANIZATION'])

    assignments = assignment_repos(repos)
    repos.select { |repo|
      ! is_assignment?(repo.name) && \
      ! is_student_repo?(assignments, repo.name)
    }
  end

end
