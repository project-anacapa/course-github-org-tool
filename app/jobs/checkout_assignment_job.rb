class CheckoutAssignmentJob < ApplicationJob
  include OctokitHelper
  include AssignmentsHelper
  queue_as :default

  def perform(assignment_name, students)
    raise "Assignment name must be a string" unless assignment_name.is_a? String
    students = Array(students) # ensure array
    assignment_name = assignment_name.clone # copy variable
    assignment_name.slice! 'assignment-'
    # an array like [lab_name, student1, student2...]
    new_repo_name = students.sort.unshift(assignment_name).join('-')
    course_org = ENV['COURSE_ORGANIZATION']

    assignment_spec = get_assignment_spec "#{course_org}/assignment-#{assignment_name}"
    logger.warn assignment_spec
    return unless assignment_spec['ready']
    starter_repo = assignment_spec['starter_repo']

    logger.warn "Creating assignment repo #{new_repo_name}"
    new_repo = machine_octokit.create_repository(new_repo_name, {
        :organization => course_org,
        :private => false, # change this to true when possible
        :auto_init => starter_repo.blank?
    })

    students.each do |username|
      logger.warn "Adding #{username} as a collaborator"
      machine_octokit.add_collaborator new_repo.full_name, username, :permission => 'push'

      logger.warn "Added #{username} as a collaborator!"
    end

    unless starter_repo.blank?
      starter_repo = machine_octokit.repo(starter_repo)
      logger.warn "Copying contents from #{starter_repo.name} into #{new_repo_name}"
      begin
        copy_items machine_octokit.contents(starter_repo.full_name), starter_repo, new_repo, machine_octokit
      rescue Exception => e
        logger.warn e
      end
    end
  end

  private

    def copy_items(base_items, from, to, client)
      base_items.each do |item|
        content = client.contents from.full_name, :path => item.path
        if content.is_a?(Array)
          copy_items(content, from, to, client)
        else
            client.create_contents to.full_name, content.path, "Creating #{content.name}", Base64.decode64(content.content)
        end
      end
    end
end
