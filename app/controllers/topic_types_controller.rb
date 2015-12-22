class TopicTypesController < ApplicationController
  before_action :set_topic_type, only: [:show, :edit, :update, :destroy]

  # GET /topic_types
  # GET /topic_types.json
  def index
    @topic_types = TopicType.all
  end

  # GET /topic_types/1
  # GET /topic_types/1.json
  def show
  end

  # GET /topic_types/new
  def new
    @topic_type = TopicType.new
  end

  # GET /topic_types/1/edit
  def edit
  end

  # POST /topic_types
  # POST /topic_types.json
  def create
    @topic_type = TopicType.new(topic_type_params)

    respond_to do |format|
      if @topic_type.save
        format.html { redirect_to @topic_type, notice: 'Topic type was successfully created.' }
        format.json { render :show, status: :created, location: @topic_type }
      else
        format.html { render :new }
        format.json { render json: @topic_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /topic_types/1
  # PATCH/PUT /topic_types/1.json
  def update
    respond_to do |format|
      if @topic_type.update(topic_type_params)
        format.html { redirect_to @topic_type, notice: 'Topic type was successfully updated.' }
        format.json { render :show, status: :ok, location: @topic_type }
      else
        format.html { render :edit }
        format.json { render json: @topic_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topic_types/1
  # DELETE /topic_types/1.json
  def destroy
    @topic_type.destroy
    respond_to do |format|
      format.html { redirect_to topic_types_url, notice: 'Topic type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_topic_type
      @topic_type = TopicType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def topic_type_params
      params.require(:topic_type).permit(:name, :description, :value_based_y_n)
    end
end
