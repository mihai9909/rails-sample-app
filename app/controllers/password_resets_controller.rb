class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]  
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      password_reset(@user)
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def update
    if params[:user][:password].empty? # Case (3)
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update(user_params) # Case (4)
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit' # Case (2)
    end
  end
    
    

  def edit
  end

  private
    def password_reset
      response = HTTParty.post("https://api.emailjs.com/api/v1.0/email/send",
        :body => {service_id: 'default_service',
                  template_id: 'template_eitmj18',
                  user_id: ENV['EMAILJS_USER_ID'],
                  template_params: {
                    to_name: user.name,
                    to_email: user.email,
                    message: edit_account_activation_url(user.activation_token,
                                                        email: user.email)
                  },
                  accessToken: ENV['EMAILJS_API_KEY']}.to_json,
                  :headers => { 'Content-Type' => 'application/json' })
    end

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # Confirms a valid user.
  def valid_user
    unless (@user && @user.activated? &&
      @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end

  # Checks expiration of reset token.
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end
  end  
end
