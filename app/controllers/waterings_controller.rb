class WateringsController < ApplicationController
  before_action :set_watering, only: %i[ show edit update destroy ]
  before_action :authorize_viewer, only: [:index, :show]
  before_action :authorize_editor, except: [:index, :show]

  # GET /waterings or /waterings.json
  def index
    if current_project.nil?
      return redirect_to projects_path, notice: t('messages.please_select_project')
    end
    @waterings = current_project&.waterings&.sort_by(&:date).reverse
  end

  # GET /waterings/1 or /waterings/1.json
  def show
  end

  # GET /waterings/new
  def new
    @watering = Watering.create plant_id: params[:plant_id], date: Time.zone.now.to_date
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to edit_watering_path(@watering) }
    end
  end

  # GET /waterings/1/edit
  def edit
  end

  # POST /waterings or /waterings.json
  def create
    @watering = Watering.new(watering_params)

    respond_to do |format|
      if @watering.save
        format.html { redirect_to watering_url(@watering), notice: t('waterings.messages.create_success') }
        format.json { render :show, status: :created, location: @watering }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @watering.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /waterings/1 or /waterings/1.json
  def update
    respond_to do |format|
      if @watering.update(watering_params)
        format.html { redirect_to watering_url(@watering), notice: t('waterings.messages.watering_updated') }
        format.json { render :show, status: :ok, location: @watering }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @watering.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /waterings/1 or /waterings/1.json
  def destroy
    @watering.destroy

    respond_to do |format|
      format.html { redirect_to waterings_url, notice: t("waterings.messages.delete_success") }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_watering
      @watering = Watering.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def watering_params
      params.require(:watering).permit(:plant_id, :date, :notes)
    end
end
