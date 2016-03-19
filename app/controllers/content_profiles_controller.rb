# == Schema Information
#
# Table name: content_profiles
#
#  id                        :integer          not null, primary key
#  person_authentication_key :string
#  profile_type_id           :integer
#  authentication_provider   :string
#  username                  :string
#  display_name              :string
#  email                     :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class ContentProfilesController < ApplicationController

  # GET /content_profiles
  def index
    @page_controls = content_profile_service.handle_content_profile_index(params)
    flash[:notice] = @page_controls.message if @page_controls.message?
  end

  # GET /content_profiles/1
  def show
    @page_controls = content_profile_service.show_and_edit_content_profile(params)
    flash[:notice] = @page_controls.message if @page_controls.message?
    redirect_to content_profiles_url unless @page_controls.success
  end

  # GET /content_profiles/new
  def new
    @page_controls = content_profile_service.make_new_content_profile()
    flash[:notice] = @page_controls.message if @page_controls.message?
  end

  # GET /content_profiles/1/edit
  def edit
    @page_controls = content_profile_service.show_and_edit_content_profile(params)
    flash[:notice] = @page_controls.message if @page_controls.message?
    redirect_to content_profiles_url unless @page_controls.success
  end

  # POST /content_profiles
  def create
    @page_controls = content_profile_service.handle_content_profile_creations(content_profile_params)
      if @page_controls.success
        redirect_to @page_controls.content_profile, notice: @page_controls.message
      else
        render :new, notice: @page_controls.message
      end
  end

  # PATCH/PUT /content_profiles/1
  def update
    @page_controls = content_profile_service.handle_content_profile_update(content_profile_params.merge(id: params[:id]))
    if @page_controls.success
      redirect_to @content_profile, notice: @page_controls.message
    else
      render :edit, notice: @page_controls.message
    end
  end

  # DELETE /content_profiles/1
  def destroy
    @page_controls = content_profile_service.handle_content_profile_destroy(params)
    redirect_to content_profiles_url, notice: @page_controls.message
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def content_profile_params
      params.require(:content_profile).permit(:person_authentication_key, :profile_type_id, :authentication_provider, :username, :display_name, :email)
    end
end
