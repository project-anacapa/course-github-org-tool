class CourseController < ApplicationController
  before_action :authenticate_user!

  def show
    @course_name = course_org_name
    @course_org = machine_octokit.org(@course_name)
    @students = Student.all
  end

end
