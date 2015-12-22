class TopicTypeOptsController < ApplicationController
  before_action :set_topic_type_opt, only: [:show, :edit, :update, :destroy]

  # GET /topic_type_opts
  # GET /topic_type_opts.json
  def index
    @topic_type_opts = TopicTypeOpt.all
  end

  # GET /topic_type_opts/1
  # GET /topic_type_opts/1.json
  def show
  end

  # GET /topic_type_opts/new
  def new
    @topic_type_opt = TopicTypeOpt.new
  end

  # GET /topic_type_opts/1/edit
  def edit
  end

  # POST /topic_type_opts
  # POST /topic_type_opts.json
  def create
    @topic_type_opt = TopicTypeOpt.new(topic_type_opt_params)

    respond_to do |format|
      if @topic_type_opt.save
        format.html { redirect_to @topic_type_opt, notice: 'Topic type opt was successfully created.' }
        format.json { render :show, status: :created, location: @topic_type_opt }
      else
        format.html { render :new }
        format.json { render json: @topic_type_opt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /topic_type_opts/1
  # PATCH/PUT /topic_type_opts/1.json
  def update
    respond_to do |format|
      if @topic_type_opt.update(topic_type_opt_params)
        format.html { redirect_to @topic_type_opt, notice: 'Topic type opt was successfully updated.' }
        format.json { render :show, status: :ok, location: @topic_type_opt }
      else
        format.html { render :edit }
        format.json { render json: @topic_type_opt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topic_type_opts/1
  # DELETE /topic_type_opts/1.json
  def destroy
    @topic_type_opt.destroy
    respond_to do |format|
      format.html { redirect_to topic_type_opts_url, notice: 'Topic type opt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_topic_type_opt
      @topic_type_opt = TopicTypeOpt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def topic_type_opt_params
      params.require(:topic_type_opt).permit(:value, :description, :topic_type_id)
    end
end
