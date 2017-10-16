class VisitorsController < ApplicationController
  def index
    @course = course_org_name
    @emails = []
    @member = nil
    # All predicate methods should return boolean
    # And not have side effects
    if user_signed_in? and is_course_setup?
      @member = is_org_member
      @emails = session_octokit.emails
    end
  end

  # /course_error
  def course_error
    unless ENV['COURSE_ORGANIZATION'].blank?
      redirect_to root_url
    end
  end
end
