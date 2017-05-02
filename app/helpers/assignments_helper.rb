module AssignmentsHelper

  def is_assignment?(repo_name)
    (repo_name =~ /^assignment-([\w\d\-_]+)$/i) == 0
  end

  def is_student_repo?(assignments, repo_name)
    assignments.any? {|a| repo_name =~ /^#{a}-([\w\d\-_]+)$/i }
  end

  def assignment_repos(repos)
    repos.select { |repo| is_assignment? repo.name }
  end

  def student_repos(repos, student=nil)
    sub_index = 'assignment-'.length
    # get the list of valid assignment names (omitting the starting 'assignment-')
    assignments = assignment_repos(repos).map {|repo| repo.name[sub_index..-1]}

    # get only repos with names that correspond to valid and known assignments
    ret = repos.select { |repo| is_student_repo? assignments, repo.name }

    if student.blank?
      ret
    else
      ret.select { |repo| machine_octokit.collaborator? repo.name, student }
    end
  end

end
