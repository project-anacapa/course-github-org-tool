class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :require_feature!
  helper_method :not_found
  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :correct_user?
  helper_method :is_course_setup?
  helper_method :course_org?
  helper_method :course_org_name
  helper_method :is_org_member

  include Strategies
  include OctokitHelper

  private

    def require_feature!(feature)
      unless FeaturesHelper.feature_enabled?(feature)
        not_found
      end
    end

    def not_found
      raise ActionController::RoutingError.new('Not Found')
    end

    def current_user
      @current_user ||= User.where(id: session[:user_id]).first
    end

    def user_signed_in?
      true if current_user
    end

    def correct_user?
      @user = User.find(params[:id])
      unless current_user == @user
        redirect_to root_url, :alert => 'Access denied.'
      end
    end

    def authenticate_user!
      unless current_user
        redirect_to root_url, :alert => 'You need to sign in for access to this page.'
      end
    end

    def require_instructor!
      unless current_user.is_instructor?
        redirect_to root_url, :alert => 'You must be an instructor to access this page.'
      end
    end

    def is_course_setup?
      unless course_org?
        redirect_to course_error_url, :alert => 'You must set up a course organization before using this application.'
      end
      s = Setting.course_setup
      !s.blank? && s
    end

    def course_org?
      !course_org_name.blank?
    end

    def course_org_name
      ENV['COURSE_ORGANIZATION']
    end

    def is_org_member(username=nil)
      if not username and current_user
        username = current_user.username
      end
      if username and course_org_name
        begin
          mo = machine_octokit
          membership = mo.org_membership(course_org_name, {user: username })
          return membership[:state]
        rescue Octokit::NotFound
          return nil
        end
      end
      nil
    end

    def session_octokit
      token = session['oauth_token'] || ''
      if token == ''
        raise 'You must be signed in'
      end

      client = Strategies::GitStrategy.get_instance(token)
      if client.is_valid
        client
      else
        reset_session
        raise 'Looks like there was an issue authorizing you. Try signing in again!'
      end
    end
end
