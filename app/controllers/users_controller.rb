class UsersController < ApplicationController
  before_filter :target_object, only: [:show, :edit, :update, :destroy]

  def index
    @counter = 0
    @users = User.paginate(page: params[:page], :per_page => 12)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(permitted)
    if @user.save
      redirect_to @user, notice: "Saved new user"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update(permitted)
      redirect_to @user, notice: "Updated user"
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: 'Destroyed user, #{@user.name}'
  end

  private

  def target_object
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    redirect_to users_url, notice: 'Requested User Not Found!'
  end

  def permitted
    # allow record to be updated without a new password every time.
    if params.key?(:user) and params[:user].key?(:roles)
      params[:user][:roles].delete("")
      params[:user][:role_groups].delete("")
    end
    unless params[:user][:password].present?
      params[:user].delete :password
      params[:user].delete :password_confirmation
    end
    params.required(:user).permit(:username, :name, :email, :password_confirmation, :password,
                                 :remember_token, :password_reset_token,
                                 :password_reset_date, :active,
                                 :file_access_token, :role_groups => [], :roles => [])
  end

end
