module AssignmentsHelper
  include OctokitHelper

  def is_assignment?(repo_name)
    (repo_name =~ /^assignment-([\w\d\-_]+)$/i) == 0
  end

  def is_student_repo?(assignments, repo_name)
    assignments.any? {|a| repo_name =~ /^#{a}-([\w\d\-_]+)$/i }
  end

  # @param [array] repos
  def assignment_repos(repos=nil)
    repos ||= machine_octokit.org_repos(ENV['COURSE_ORGANIZATION'])
    repos.select { |repo| is_assignment? repo.name }
  end

  def assignment_names(repos=nil)
    repos ||= machine_octokit.org_repos(ENV['COURSE_ORGANIZATION'])
    sub_index = 'assignment-'.length
    # get the list of valid assignment names (omitting the starting 'assignment-')
    assignment_repos(repos).map {|repo| repo.name[sub_index..-1]}
  end

  # @param [array] repos
  def student_repos(repos=nil)
    repos ||= machine_octokit.org_repos(ENV['COURSE_ORGANIZATION'])
    sub_index = 'assignment-'.length
    # get the list of valid assignment names (omitting the starting 'assignment-')
    assignments = assignment_repos(repos).map {|repo| repo.name[sub_index..-1]}

    # get only repos with names that correspond to valid and known assignments
    repos.select { |repo| is_student_repo? assignments, repo.name }
  end

end
