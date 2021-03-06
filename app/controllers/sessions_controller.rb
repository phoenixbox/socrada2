class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    logger.debug auth
    #user = User.find_by_uid(auth["uid"]) || User.create_with_omniauth(auth)
    user = User.create_with_omniauth(auth)
    session[:uid] = user.uid
    redirect_to user_path(user.uid), notice: "Successfully signed in!"
  end

  def destroy
    session[:uid] = nil
    redirect_to root_path, notice: "Signed Out!"
  end
end
