AnacapaJenkinsAPI.configure(YAML.load_file("./jenkins.yml"))

class GenerateGradeJob < ApplicationJob
  queue_as :default

  def perform(payload)
    name = payload['name'] # along the lines of `AnacapaGrader <domain> <org> (grader|assignment)-<lab>`
    build = payload['build']
    status = build['status']

    match = /^AnacapaGrader (?<domain>\S+) (?<org>\S+) (?<type>grader|assignment)-(?<lab>\S+)$/i =~ name

    logger.warn(payload)

    if match != 0 # or domain != ENV['GIT_PROVIDER_URL'] or org != ENV['COURSE_ORGANIZATION']
      return
    end

    logger.warn(" Domain: #{domain} \n Org: #{org} \n Type: #{type} \n Lab: #{lab} ")

    if type == 'grader'
      student = build['parameters']['github_user']
      logger.warn("Graded assignment for #{student}")

      if build['artifacts'].key?('grade.json')
        logger.warn('grade:')
        grade = AnacapaJenkinsAPI.make_request(build['artifacts']['grade.json']['archive']).body
        logger.warn grade
      else
        logger.warn('No grade available!')
      end
    elsif type == 'assignment'
      # do nothing?
    else # not identified? not possible?
      # ignored
    end
  end
end
