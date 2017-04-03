class CourseController < ApplicationController
  before_action :authenticate_user!

  def show
    @course_name = Setting.course
    @course_org = nil
    if !@course_name.blank?
      mo = machine_octokit
      @course_org = mo.org(@course_name)
    else
      @course_name = 'Not Available Yet'
    end
    @students = Student.all
  end

  def setup
    if !Setting.course.blank?
      redirect_to course_path, alert: 'A course has already been set up for this application'
    else
      client = session_octokit
      @memberships = client.org_memberships
    end
  end

  def set_org
    org_name = params[:org_name]
    client = session_octokit
    membership = client.org_membership(org_name)
    if membership['role'] != 'admin'
      flash[:alert] = 'You must be the owner of the organization you will use for your course'
      redirect_to course_setup_path
    else
      add_machine_user_to_org(org_name)
      Setting['course'] = org_name
      instructors = Setting['instructors'] || []
      instructors << current_user.username
      Setting['instructors'] = instructors
      flash[:notice] = 'Successfully setup course'

      redirect_to course_path
    end
  end

  private

    def add_machine_user_to_org(org_name)
      client = session_octokit
      client.update_org_membership(org_name, {
        role: 'admin',
        state: 'pending',
        user: ENV['MACHINE_USER_NAME']
      })
      mo = machine_octokit
      mo.update_org_membership(org_name, {
        state: 'active',
      })
    end
end
