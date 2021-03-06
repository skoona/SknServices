
class UsersController < ApplicationController
  before_action :target_object, only: [:show, :edit, :update, :destroy]

  def index
    @page_controls = access_service.handle_users_index(params)
  end

  def show
  end

  def new
    @user = User.new
    @page_controls = access_service.get_user_form_options
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
    @page_controls = access_service.get_user_form_options
  end

  def update
    if @user.update(permitted)
      redirect_to root_url, notice: "Updated user" and return unless current_user_has_access?('users/index')
      redirect_to users_url, notice: "Updated user"
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
    redirect_to users_url, notice: 'Requested object Not Found!'
  end

  def permitted
    # allow record to be updated without a new password every time.
    if params.key?(:user) and params[:user].key?(:roles)
      params[:user][:assigned_roles].delete("")
      params[:user][:assigned_groups].delete("")
      params[:user][:user_options].delete("")
      params[:user][:roles].delete("")
    end
    unless params[:user][:password].present?
      params[:user].delete :password
      params[:user].delete :password_confirmation
    end
    params.required(:user).permit(:username, :name, :email, :password_confirmation, :password,
                                 :remember_token, :password_reset_token,
                                 :password_reset_date, :active,
                                 :file_access_token,
                                 :user_options => [],
                                 :roles => [],
                                 :assigned_groups => [],
                                 :assigned_roles => [])
  end

end
