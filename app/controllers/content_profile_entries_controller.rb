class ContentProfileEntriesController < ApplicationController
  before_action :set_content_profile_entry, only: [:show, :edit, :update, :destroy]

  # GET /content_profile_entries
  # GET /content_profile_entries.json
  def index
    @content_profile_entries = ContentProfileEntry.all
  end

  # GET /content_profile_entries/1
  # GET /content_profile_entries/1.json
  def show
  end

  # GET /content_profile_entries/new
  def new
    @content_profile_entry = ContentProfileEntry.new
  end

  # GET /content_profile_entries/1/edit
  def edit
  end

  # POST /content_profile_entries
  # POST /content_profile_entries.json
  def create
    @content_profile_entry = ContentProfileEntry.new(content_profile_entry_params)

    respond_to do |format|
      if @content_profile_entry.save
        format.html { redirect_to @content_profile_entry, notice: 'Content profile entry was successfully created.' }
        format.json { render :show, status: :created, location: @content_profile_entry }
      else
        format.html { render :new }
        format.json { render json: @content_profile_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /content_profile_entries/1
  # PATCH/PUT /content_profile_entries/1.json
  def update
    respond_to do |format|
      if @content_profile_entry.update(content_profile_entry_params)
        format.html { redirect_to @content_profile_entry, notice: 'Content profile entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @content_profile_entry }
      else
        format.html { render :edit }
        format.json { render json: @content_profile_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /content_profile_entries/1
  # DELETE /content_profile_entries/1.json
  def destroy
    @content_profile_entry.destroy
    respond_to do |format|
      format.html { redirect_to content_profile_entries_url, notice: 'Content profile entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_content_profile_entry
      @content_profile_entry = ContentProfileEntry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def content_profile_entry_params
      params.require(:content_profile_entry).permit(:topic_value, :content_value, :content_type_id, :topic_type_id, :content_profile_id)
    end
end
