module AssignmentsHelper

  def assignment_repos(repos)
    repos.select { |repo| repo.name =~ /^assignment-([\w\d\-_]+)$/i }
  end

  def student_repos(repos)
    sub_index = 'assignment-'.length
    # get the list of valid assignment names
    assignments = assignment_repos(repos).map {|repo| repo.name[sub_index..-1]}

    # get only repos with names that correspond to valid and known assignments
    repos.select do |repo|
      assignments.any? {|a| repo.name =~ /^#{a}-([\w\d\-_]+)$/i }
    end
  end

end
