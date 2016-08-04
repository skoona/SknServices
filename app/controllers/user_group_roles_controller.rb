# == Schema Information
#
# Table name: user_group_roles
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  group_type  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class UserGroupRolesController < ApplicationController
  before_action :set_user_group_role, only: [:show, :edit, :update, :destroy]

  # GET /user_group_roles
  # GET /user_group_roles.json
  def index
    @user_group_roles = UserGroupRole.paginate(page: params[:page], :per_page => 12)
  end

  # GET /user_group_roles/1
  # GET /user_group_roles/1.json
  def show
    @page_controls = access_service.role_select_options
  end

  # GET /user_group_roles/new
  def new
    @user_group_role = UserGroupRole.new
    @page_controls = access_service.role_select_options
  end

  # GET /user_group_roles/1/edit
  def edit
    @page_controls = access_service.role_select_options
  end

  # POST /user_group_roles
  # POST /user_group_roles.json
  def create
    @user_group_role = UserGroupRole.new(user_group_role_params)

    respond_to do |format|
      if @user_group_role.save
        format.html { redirect_to @user_group_role, notice: 'User group role was successfully created.' }
        format.json { render :show, status: :created, location: @user_group_role }
      else
        format.html { render :new }
        format.json { render json: @user_group_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_group_roles/1
  # PATCH/PUT /user_group_roles/1.json
  # Parameters: {
  #   "user_group_role"=>{
  #       "name"=>"EmployeePrimary",
  #       "description"=>"BMI Admin User",
  #       "group_type"=>"BMI Admin",
  #       "user_role_ids"=>["1", "2", "3", "4", "5", "6", "7", "8", "10", "12", ""]
  #   },
  #   "commit"=>"Update User group role",
  #   "id"=>"1"
  # }
  def update
    respond_to do |format|
      if @user_group_role.update(user_group_role_params)
        format.html { redirect_to @user_group_role, notice: 'User group role was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_group_role }
      else
        format.html { render :edit }
        format.json { render json: @user_group_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_group_roles/1
  # DELETE /user_group_roles/1.json
  def destroy
    @user_group_role.destroy
    respond_to do |format|
      format.html { redirect_to user_group_roles_url, notice: 'User group role was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_group_role
      @user_group_role = UserGroupRole.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      redirect_to user_group_roles_url, notice: 'Requested object Not Found!'
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_group_role_params
      params[:user_group_role][:user_role_ids].delete("")
      params.require(:user_group_role).permit(:name, :description, :group_type, user_role_ids: [])
    end
end
