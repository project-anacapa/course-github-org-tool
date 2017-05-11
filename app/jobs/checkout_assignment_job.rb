class CheckoutAssignmentJob < ApplicationJob
  queue_as :default

  def perform(assignment_name, students)
    assignment_name.slice! 'assignment-'
    new_repo_name = Array(students).sort.unshift(assignment_name).join('-')
    logger.warn "Creating assignment repo #{new_repo_name}"
  end
end
