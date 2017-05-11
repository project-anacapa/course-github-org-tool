class CheckoutAssignmentJob < ApplicationJob
  include OctokitHelper
  include AssignmentsHelper
  queue_as :default

  def perform(assignment_name, students)
    raise "Assignment name must be a string" unless assignment_name.is_a? String
    students = Array(students) # ensure array
    assignment_name = assignment_name.clone # copy variable to make sure we don't update calling scope in next call
    assignment_name.slice! 'assignment-'
    # an array like [lab_name, student1, student2...]
    new_repo_name = students.sort.unshift(assignment_name).join('-')
    course_org = ENV['COURSE_ORGANIZATION']
    new_repo_fullname = "#{course_org}/#{new_repo_name}"

    assignment_spec = get_assignment_spec "#{course_org}/assignment-#{assignment_name}"
    logger.warn assignment_spec
    return unless assignment_spec['ready']
    starter_repo = assignment_spec['starter_repo']

    new_repo = machine_octokit.repo(new_repo_fullname)
    existed = ! new_repo.blank?

    if ! existed
      logger.warn "Creating assignment repo #{new_repo_name}"
      new_repo = machine_octokit.create_repository(new_repo_name, {
          :organization => course_org,
          :private => false, # change this to true when we know that private repos are feasible.
          :auto_init => starter_repo.blank?
      })
    else
      logger.warn "Assignment repo #{new_repo_name} already exists! Ensuring proper settings"
      # machine_octokit.set_private(new_repo_fullname)
    end

    students.each do |username|
      logger.warn "Adding #{username} as a collaborator"
      begin
        machine_octokit.add_collaborator new_repo.full_name, username, :permission => 'push'
        logger.warn "Successfully added #{username} as a collaborator!"
      rescue Exception => e
        logger.warn "Could not add #{username} as a collaborator. Error below:"
        logger.warn e
      end
    end

    if starter_repo.blank?
      logger.warn "No starter code repo to copy..."
    elsif existed
      logger.warn "Repository already existed; cowardly refusing to copy contents from starter code repo..."
    else
      starter_repo = machine_octokit.repo(starter_repo)
      logger.warn "Copying contents from #{starter_repo.name} into #{new_repo_name}"
      begin
        copy_items machine_octokit.contents(starter_repo.full_name), starter_repo, new_repo, machine_octokit
      rescue Exception => e
        logger.warn "There was an issue copying files from the starter code repo to the new student repo. Error below:"
        logger.warn e
      end
    end

    logger.warn "Assignment checkout complete for `#{assignment_name}` by #{students}!"
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
