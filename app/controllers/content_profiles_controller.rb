class ContentProfilesController < ApplicationController
  before_action :set_content_profile, only: [:show, :edit, :update, :destroy]

  # GET /content_profiles
  # GET /content_profiles.json
  def index
    @content_profiles = ContentProfile.paginate(page: params[:page], :per_page => 12)
  end

  # GET /content_profiles/1
  # GET /content_profiles/1.json
  def show
  end

  # GET /content_profiles/new
  def new
    @content_profile = ContentProfile.new
  end

  # GET /content_profiles/1/edit
  def edit
  end

  # POST /content_profiles
  # POST /content_profiles.json
  def create
    @content_profile = ContentProfile.new(content_profile_params)

    respond_to do |format|
      if @content_profile.save
        format.html { redirect_to @content_profile, notice: 'Content profile was successfully created.' }
        format.json { render :show, status: :created, location: @content_profile }
      else
        format.html { render :new }
        format.json { render json: @content_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /content_profiles/1
  # PATCH/PUT /content_profiles/1.json
  def update
    respond_to do |format|
      if @content_profile.update(content_profile_params)
        format.html { redirect_to @content_profile, notice: 'Content profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @content_profile }
      else
        format.html { render :edit }
        format.json { render json: @content_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /content_profiles/1
  # DELETE /content_profiles/1.json
  def destroy
    @content_profile.destroy
    respond_to do |format|
      format.html { redirect_to content_profiles_url, notice: 'Content profile was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_content_profile
      @content_profile = ContentProfile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def content_profile_params
      params.require(:content_profile).permit(:person_authentication_key, :profile_type_id, :authentication_provider, :username, :display_name, :email)
    end
end
