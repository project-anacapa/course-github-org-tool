class GenerateGradeJob < ApplicationJob
  queue_as :default

  def perform(payload)
    name = payload['name'] # along the lines of `AnacapaGrader <domain> <org> (grader|assignment)-<lab>`
    status = payload['build']['status']

    match = /^AnacapaGrader (?<domain>\S+) (?<org>\S+) (?<type>grader|assignment)-(?<lab>\S+)$/i =~ name

    logger.warn(payload)

    if match != 0 # or domain != ENV['GIT_PROVIDER_URL'] or org != ENV['COURSE_ORGANIZATION']
      return
    end

    logger.warn("Domain: #{domain}")
    logger.warn("Org: #{org}")
    logger.warn("Type: #{type}")
    logger.warn("Lab: #{lab}")

    if type == 'grader'
      student = payload['build']['parameters']['github_user']
      logger.warn("Grading assignment for #{student}")
    elsif type == 'assignment'
      # do nothing?
    else # not identified? not possible?
      # ignored
    end
  end
end
