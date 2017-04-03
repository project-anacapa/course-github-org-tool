class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_instructor!, :except => [:match_to_student]
  before_action :correct_user?, :only => [:show]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def settings
    @user_settings = current_user.settings
  end

  def update_settings
    current_user.settings['discoverable'] = params[:discoverable] == '1'
    redirect_to settings_path, notice: 'Settings have been updated'
  end

  def toggle_instructor_privilege
    user = User.find(params[:id])
    if is_instructor?
      if user == current_user
        redirect_to users_path, alert: 'You can\'t change yourself'
      elsif is_instructor? user
        instructors = Setting['instructors']
        instructors -= [user.username]
        Setting['instructors'] = instructors
        redirect_to users_path, notice: "Successfully demoted #{user.username} to non-instructor"
      else
        instructors = Setting['instructors'] || []
        instructors << user.username
        Setting['instructors'] = instructors
        redirect_to users_path, notice: "Successfully promoted #{user.username} to instructor"
      end
    else
      redirect_to users_path, alert: 'You must be an instructor to elect other instructors'
    end
  end

  def match_to_student
    @user = User.find(params[:id])
    matched = @user.attempt_match_to_student(session_octokit, machine_octokit)
    if matched
      flash[:notice] = 'Successfully matched you to a student record.'
    else
      flash[:alert] = 'We could not match you to a student record.'
    end
    redirect_to root_url
  end

end
