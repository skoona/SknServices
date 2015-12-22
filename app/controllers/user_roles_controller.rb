class UserRolesController < ApplicationController
  before_action :set_user_role, only: [:show, :edit, :update, :destroy]

  # GET /user_roles
  # GET /user_roles.json
  def index
    @user_roles = UserRole.all
  end

  # GET /user_roles/1
  # GET /user_roles/1.json
  def show
  end

  # GET /user_roles/new
  def new
    @user_role = UserRole.new
  end

  # GET /user_roles/1/edit
  def edit
  end

  # POST /user_roles
  # POST /user_roles.json
  def create
    @user_role = UserRole.new(user_role_params)

    respond_to do |format|
      if @user_role.save
        format.html { redirect_to @user_role, notice: 'User role was successfully created.' }
        format.json { render :show, status: :created, location: @user_role }
      else
        format.html { render :new }
        format.json { render json: @user_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_roles/1
  # PATCH/PUT /user_roles/1.json
  def update
    respond_to do |format|
      if @user_role.update(user_role_params)
        format.html { redirect_to @user_role, notice: 'User role was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_role }
      else
        format.html { render :edit }
        format.json { render json: @user_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_roles/1
  # DELETE /user_roles/1.json
  def destroy
    @user_role.destroy
    respond_to do |format|
      format.html { redirect_to user_roles_url, notice: 'User role was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_role
      @user_role = UserRole.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_role_params
      params.require(:user_role).permit(:name, :description)
    end
end
