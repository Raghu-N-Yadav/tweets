class PasswordResetsController < ApplicationController

  def new
  end

  def create
    @user = User.find_by(email: params[:email])

    if @user.present?
      #send email
      PasswordMailer.with(user: @user).reset.deliver_now
    end
    redirect_to root_path, notice: "Check your mail to Reset Password"
  end

  def edit
    @user = User.find_signed!(params[:token], purpose: "reset_password")

  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to sign_in_path, alert: "your token has expired. Pls try again"
  end

  def update
    @user = User.find_signed!(params[:token], purpose: "reset_password")

    if @user.update(password_params)
      redirect_to sign_in_path, notice: "Login with new password now"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
  
  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end