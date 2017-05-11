module AssignmentsHelper
  include OctokitHelper

  def is_assignment?(repo_name)
    (repo_name =~ /^assignment-([\w\d\-_]+)$/i) == 0
  end

  def is_student_repo?(assignments, repo_name)
    assignments.any? {|a| repo_name =~ /^#{a}-([\w\d\-_]+)$/i }
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
        begin
          spec = machine_octokit.contents(repo.full_name, '.anacapa/assignment_spec.json')
          JSON.parse(Base64.decode64(spec.content))['ready']
        rescue Exception => e
          logger.warn e
          false
        end
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

    if student.blank?
      ret
    else
      ret = ret.select { |repo| machine_octokit.collaborator? "#{course}/#{repo.name}", student }
      if assignment.blank?
        ret
      else
        ret.select { |repo| repo.name.include? assignment.split("assignment-").last }
      end
    end
  end

end
