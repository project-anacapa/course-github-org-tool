AnacapaJenkinsAPI.configure(YAML.load_file("./jenkins.yml"))

class GenerateGradeJob < ApplicationJob
  include OctokitHelper
  include AssignmentsHelper
  queue_as :default

  def perform(payload)
    logger.warn(payload)

    name = payload['name'] # along the lines of `AnacapaGrader <domain> <org> (grader|assignment)-<lab>`
    build = payload['build']
    return unless build['status'] == 'SUCCESS'

    match = /^AnacapaGrader (?<domain>\S+) (?<org>\S+) (?<type>grader|assignment)-(?<lab>\S+)$/i =~ name
    return unless match == 0 # and domain == ENV['GIT_PROVIDER_URL'] and org == ENV['COURSE_ORGANIZATION']

    logger.warn(" Domain: #{domain} \n Org: #{org} \n Type: #{type} \n Lab: #{lab} ")

    if type == 'grader'
      student = build['parameters']['github_user']
      logger.warn("Graded assignment for #{student}")

      if build['artifacts'].key?('grade.json')
        grade = AnacapaJenkinsAPI.make_request(build['artifacts']['grade.json']['archive']).body
        self.update_feedback(grade, org, lab, student)
      else
        logger.warn('No grade available!')
      end
    elsif type == 'assignment'
      # do nothing?
    else # not identified? not possible?
      # ignored
    end
  end

  def update_feedback(grade, org, lab, student)
    logger.warn(grade)
    student_repo = "#{org}/#{lab}-#{student}"
    students = get_students(student_repo)

    feedback_file = "#{lab}/FEEDBACK.md"
    grade_file = "#{lab}/README.md"

    students.each do |s|
      feedback_repo_name = "FEEDBACK-#{s}"
      feedback_repo_fullname = "#{org}/#{feedback_repo_name}"

      feedback_repo = machine_octokit.repo(feedback_repo_fullname)
      existed = ! feedback_repo.blank?

      if ! existed
        logger.warn "Creating assignment repo #{feedback_repo_fullname}"
        feedback_repo = machine_octokit.create_repository(feedback_repo_name, {
            :organization => org,
            :private => false, # change this to true when we know that private repos are feasible.
        })
      else
        logger.warn "Assignment repo #{feedback_repo_fullname} already exists! Ensuring proper settings"
        # machine_octokit.set_private(new_repo_fullname)
      end

      logger.warn "Adding #{s} as a collaborator"
      begin
        machine_octokit.add_collaborator feedback_repo.full_name, s, :permission => 'pull'
        logger.warn "Successfully added #{s} as a collaborator!"
      rescue Exception => e
        logger.warn "Could not add #{s} as a collaborator. Error below:"
        logger.warn e
      end

      begin
        # this will raise an exception if it doesn't exist
        machine_octokit.contents(feedback_repo.full_name, :path => feedback_file)
        logger.warn("Feedback file already exists.. continuing")
      rescue
        # create the feedback file if it doesn't already exist
        logger.warn("Creating feedback file for this lab as #{feedback_file}")
        machine_octokit.create_contents \
                feedback_repo.full_name,
                feedback_file,
                "Creating feedback file for lab #{lab}",
                "# Feedback on #{lab} for #{s}"
      end

      grade_readme = create_grade_readme(JSON.parse(grade))
      begin
        logger.warn("Creating grade file for lab #{grade_file}")
        machine_octokit.create_contents \
                feedback_repo.full_name,
                grade_file,
                "Create Grade for lab #{lab}",
                grade_readme
      rescue
        logger.warn("#{grade_file} already existed. using update instead")
        contents = machine_octokit.contents(feedback_repo.full_name, :path => grade_file)
        machine_octokit.update_contents \
                feedback_repo.full_name,
                grade_file,
                "Update Grade for lab #{lab}",
                contents['sha'],
                grade_readme
      end

      logger.warn("completed generating grade output!")
    end
  end

  def create_grade_readme(grade)
    readme = %{
# Latest Grade

For instructor-provided feedback, visit [the Feedback.md file](FEEDBACK.md).

| Test Name | Command | Value |
| --------- | ------- | ----- |
    }.strip

    total, max = 0, 0
    readme << "\n"
    grade['results'].each do |g|
      total += g['score']
      max += g['max_score']
      readme << "| #{g['test_group']} | #{g['test_name']} | #{g['max_score']} |\n"
    end

    readme << "\n"
    readme << %{
Total Score: #{total} / #{max}

*Note*: this score is tentative.

*Note*: Do not make edits to this file, as any changes will be overwritten on the next grade run.

In the future, below would be the diffs for each of the failed test cases!
    }.strip

    readme
  end

  def update_official_grade(grade, org, lab, student)

  end
end
