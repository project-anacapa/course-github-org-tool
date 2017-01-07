class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :correct_user?
  helper_method :is_course_setup?
  helper_method :is_instructor?
  helper_method :is_org_member

  private
    def current_user
      @current_user ||= User.where(id: session[:user_id]).first
    end

    def user_signed_in?
      return true if current_user
    end

    def correct_user?
      @user = User.find(params[:id])
      unless current_user == @user
        redirect_to root_url, :alert => "Access denied."
      end
    end

    def authenticate_user!
      if !current_user
        redirect_to root_url, :alert => 'You need to sign in for access to this page.'
      end
    end

    def require_instructor!
      if !is_instructor?
        redirect_to root_url, :alert => 'You must be an instructor to access this page.'
      end
    end

    def is_course_setup?
      course = Setting.course
      return !course.blank?
    end

    def is_instructor?(user=nil)
      user = user || current_user
      instructors = Setting.instructors
      return !user.blank? && !instructors.blank? && \
             instructors.is_a?(Array) && instructors.include?(user.username)
    end

    def is_org_member(username=nil)
      if not username and current_user
        username = current_user.username
      end
      if username and Setting.course
        begin
          mo = machine_octokit
          membership = mo.org_membership(Setting.course, { user: username })
          return membership.state
        rescue Octokit::NotFound
          return nil
        end
      end
      return nil
    end

    def anon_octokit
      Octokit::Client.new \
        :client_id => ENV['OMNIAUTH_PROVIDER_KEY'],
        :client_secret => ENV['OMNIAUTH_PROVIDER_SECRET']
    end

    def machine_octokit
      Octokit::Client.new \
        :access_token => ENV['MACHINE_USER_KEY']
    end

    def session_octokit
      token = session['oauth_token'] || ""
      if token == ""
        raise "You must be signed in"
      end
      Octokit::Client.new \
        :access_token => token
    end
end
