class SessionsController < ApplicationController

  def new
    if course_org?
      redirect_to '/auth/github'
    else
      redirect_to course_error_path
    end
  end

  def create
    auth = request.env['omniauth.auth']
    user = User.where(:provider => auth['provider'],
                      :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth)
    reset_session
    session[:user_id] = user.id
    session[:oauth_token] = auth[:credentials][:token]
    if is_course_setup?
      user.attempt_match_to_student(session_octokit, machine_octokit)
    else
      user.instructorize(session_octokit, machine_octokit)
    end
    redirect_to root_url, :notice => 'Signed in!'
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end

end
