class ContentTypeOptsController < ApplicationController
  before_action :set_content_type_opt, only: [:show, :edit, :update, :destroy]

  # GET /content_type_opts
  # GET /content_type_opts.json
  def index
    @content_type_opts = ContentTypeOpt.all
  end

  # GET /content_type_opts/1
  # GET /content_type_opts/1.json
  def show
  end

  # GET /content_type_opts/new
  def new
    @content_type_opt = ContentTypeOpt.new
  end

  # GET /content_type_opts/1/edit
  def edit
  end

  # POST /content_type_opts
  # POST /content_type_opts.json
  def create
    @content_type_opt = ContentTypeOpt.new(content_type_opt_params)

    respond_to do |format|
      if @content_type_opt.save
        format.html { redirect_to @content_type_opt, notice: 'Content type opt was successfully created.' }
        format.json { render :show, status: :created, location: @content_type_opt }
      else
        format.html { render :new }
        format.json { render json: @content_type_opt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /content_type_opts/1
  # PATCH/PUT /content_type_opts/1.json
  def update
    respond_to do |format|
      if @content_type_opt.update(content_type_opt_params)
        format.html { redirect_to @content_type_opt, notice: 'Content type opt was successfully updated.' }
        format.json { render :show, status: :ok, location: @content_type_opt }
      else
        format.html { render :edit }
        format.json { render json: @content_type_opt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /content_type_opts/1
  # DELETE /content_type_opts/1.json
  def destroy
    @content_type_opt.destroy
    respond_to do |format|
      format.html { redirect_to content_type_opts_url, notice: 'Content type opt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_content_type_opt
      @content_type_opt = ContentTypeOpt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def content_type_opt_params
      params.require(:content_type_opt).permit(:value, :description, :content_type_id)
    end
end
