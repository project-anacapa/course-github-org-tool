AnacapaJenkinsAPI.configure({
    :server_url => ENV['JENKINS_HOST'],
    :username => ENV['JENKINS_USER'],
    :password => ENV['JENKINS_USER_KEY']
})

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
      students = get_students("#{org}/#{lab}-#{student}")
      logger.warn("Graded assignment for #{student}")

      # if a grade was generated
      if build['artifacts'].key?('grade.json')
        grade = AnacapaJenkinsAPI.make_request(build['artifacts']['grade.json']['archive']).body
        # feedback shown to students
        self.update_feedback(grade, org, lab, students, build['artifacts'])
        # feedback shown to instructors
        self.update_official_grade(JSON.parse(grade), org, lab, students)
      else
        logger.warn('No grade available!')
      end
    elsif type == 'assignment'
      # do nothing?
    else # not identified? not possible?
      # ignored
    end
  end

  def update_feedback(grade, org, lab, students, artifacts)
    logger.warn(grade)
    feedback_file = "#{lab}/FEEDBACK.md"
    grade_file = "#{lab}/README.md"

    students.each do |s|
      feedback_repo_name = "FEEDBACK-#{s}"

      feedback_repo = ensure_repo(machine_octokit, org, feedback_repo_name, true)

      logger.warn "Adding #{s} as a collaborator"
      begin
        machine_octokit.add_collaborator feedback_repo.full_name, s, :permission => 'pull'
        logger.warn "Successfully added #{s} as a collaborator!"
      rescue Exception => e
        logger.warn "Could not add #{s} as a collaborator. Error below:"
        logger.warn e
      end

      begin
        # this will raise an exception if the feedback file doesn't exist yet
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

      grade_readme = create_grade_readme(JSON.parse(grade), artifacts)
      begin
        logger.warn("Creating grade file for lab #{grade_file}")
        machine_octokit.create_contents \
                feedback_repo.full_name,
                grade_file,
                "Create Grade for lab #{lab}",
                grade_readme
      rescue
        logger.warn("#{grade_file} already existed. using update instead")
        existing_file = machine_octokit.contents(feedback_repo.full_name, :path => grade_file)
        machine_octokit.update_contents \
                feedback_repo.full_name,
                grade_file,
                "Update Grade for lab #{lab}",
                existing_file['sha'],
                grade_readme
      end

      logger.warn("completed generating grade output!")
    end
  end

  def create_grade_readme(grade, artifacts)
    green_box = "![#7fcb5c](https://placehold.it/15/7fcb5c/000000?text=+)"
    red_box = "![#c94114](https://placehold.it/15/c94114/000000?text=+)"

    passed = []
    failed = []

    total, max = 0, 0
    grade['results'].each do |g|
      total += number_or_zero(g['score'])
      max += number_or_zero(g['max_score'])
      if number_or_zero(g['score']) == 0
        failed << g
      else
        passed << g
      end
    end

    readme = %{
# Latest Grade for Repository: `#{grade['assignment_name']}`

Repository: `#{grade['repo']}`

For instructor-provided feedback, visit [the FEEDBACK.md file](FEEDBACK.md).

Total Score: `#{total} / #{max}`

*__Note__*: this score is tentative.

*__Instructor Note__*: Do not make edits to this file; any changes will be overwritten on the next grade generation.

## Passed Tests

| Test Group | Test Name | Value |
| ---------- | --------- | ----- |
    }.strip

    passed.each do |g|
      readme << "\n| #{g['test_group']} | #{green_box} #{g['test_name']} | #{g['max_score']} |"
    end

    readme << "\n"
    readme << %{
## Failed Tests

| Test Group | Test Name | Value |
| ---------- | --------- | ----- |
    }.strip

    failed.each do |g|
      readme << "\n| #{g['test_group']} | #{red_box} #{g['test_name']} | #{g['max_score']} |"
    end

    failed.each do |g|
      readme << "\n\n"
      readme << %{
### #{g['test_group']}:#{g['test_name']} -- Your program's output did not match the expected.

Expected output is on the left, your output is on the right.

```diff
      }.strip

      diff_name = "#{g['test_group']}_#{g['test_name']}_output".gsub(/\W+/, '_')
      diff_name = "#{diff_name}.diff"
      readme << "\n"
      if g['hide'] || false
        readme << "Output obfuscated by instructor.\n"
      elsif artifacts.key?(diff_name)
        readme << AnacapaJenkinsAPI.make_request(artifacts[diff_name]['archive']).body
      else
        readme << "No output available to display.\n"
      end
      readme << "\n```\n"
    end

    readme
  end

  def update_official_grade(grade, org, lab, students)
    csv_header = %w[id username grade_latest grade_highest grade_max]

    grades_repo = ensure_repo(machine_octokit, org, 'grades', true)
    grade_file = "#{lab}.csv"

    total, max = 0, 0
    grade['results'].each do |g|
      total += number_or_zero(g['score'])
      max += number_or_zero(g['max_score'])
    end

    begin
      # if the grades file already exists, update the contents to reflect the new grade
      existing_file = machine_octokit.contents(grades_repo.full_name, :path => grade_file)
      contents = parse_csv(Base64.decode64(existing_file.content))

      logger.warn("#{grade_file} exists. Updating grades...")
      students.each do |s|
        # get the old value (or create a new hash)
        old_grade = contents.detect { |g| g['username'] == s } || Hash[csv_header.product([''])]
        # then delete the old value while we update it with new info
        contents.delete_if { |g| g['username'] == s }
        contents << gen_grade(old_grade, total, max, s)
      end
      machine_octokit.update_contents \
                grades_repo.full_name,
                grade_file,
                "Update Grades for #{students.sort.join('-')}",
                existing_file['sha'],
                gen_csv(csv_header, contents)
    rescue
      logger.warn("Creating file with initial grade for lab #{lab}-#{students.sort.join('-')}")
      contents = []
      students.each do |s|
        contents << gen_grade(Hash[csv_header.product([''])], total, max, s)
      end
      machine_octokit.create_contents \
                grades_repo.full_name,
                grade_file,
                "Creating file with initial grade for #{students.sort.join('-')}",
                gen_csv(csv_header, contents)
    end
    logger.warn("updated official grades file")
  end

  def gen_grade(old_grade, total, max, student)
    # todo: determine whether a clone is necessary
    new_grade = old_grade#.clone
    new_grade['id'] = Student.where(username: student).first
    new_grade['username'] = student
    new_grade['grade_latest'] = total
    if number_or_zero(new_grade['grade_highest']) <= total
      new_grade['grade_highest'] = total
    end
    new_grade['grade_max'] = max
    new_grade
  end

  def number_or_zero(string)
    Integer(string || '')
  rescue ArgumentError
    0
  end

  def parse_csv(csv_string)
    lines = csv_string.split(/\n/).reject { |s| s.empty? }
    headers = lines.shift.split(/,/)
    items = []
    lines.each do |l|
      items << Hash[headers.zip(l.split(/,/))]
    end
    items
  end

  def gen_csv(headers, items)
    # this method might be a bit slow, unfortunately...
    csv_strings = [headers.join(',')]
    items.each do |item|
      vals = []
      headers.each do |h|
        vals << item[h]
      end
      csv_strings << vals.join(',')
    end
    csv_strings.join("\n")
  end
end
