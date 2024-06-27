class PlantsController < ApplicationController
  before_action :set_plant, only: %i[ show edit update destroy ]
  before_action :authenticate

  def water
    @plant = Plant.find params[:plant_id]
    redirect_to new_watering_path(plant_id: @plant.id)
  end

  # GET /plants or /plants.json
  def index
    @plants = Plant.where(archived: false).sort do |a,b|
      if a.suggested_watering.nil?
        1
      elsif b.suggested_watering.nil?
        0
      else
        a.suggested_watering <=> b.suggested_watering
      end
    end
    @scheduled_today = @plants.select { |p| p.time_until_watering && p.time_until_watering <= 0 }
    # @upcoming = @plants.select { |p| p.suggested_watering && p.suggested_watering < Time.now + 1.week}
    @upcoming = @plants.select { |p| p.suggested_watering && p.suggested_watering > Time.now}
    @recently = @plants.select { |p| p.last_watering && p.last_watering > Time.now - 1.week}.sort_by { |p| p.last_watering }.reverse
    @unscheduled = @plants - @scheduled_today - @upcoming - @recently
  end

  # GET /plants/1 or /plants/1.json
  def show
  end

  # GET /plants/new
  def new
    @plant = Plant.new
  end

  # GET /plants/1/edit
  def edit
  end

  # POST /plants or /plants.json
  def create
    @plant = Plant.new(plant_params)

    respond_to do |format|
      if @plant.save
        format.html { redirect_to plant_url(@plant), notice: "Plant was successfully created." }
        format.json { render :show, status: :created, location: @plant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @plant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plants/1 or /plants/1.json
  def update
    respond_to do |format|
      if @plant.update(plant_params)
        format.html { redirect_to plant_url(@plant), notice: "Plant was successfully updated." }
        format.json { render :show, status: :ok, location: @plant }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @plant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plants/1 or /plants/1.json
  def destroy
    @plant.destroy

    respond_to do |format|
      format.html { redirect_to plants_url, notice: "Plant was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plant
      @plant = Plant.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def plant_params
      params.require(:plant).permit(:name, :uid, :location, :pot, :archived, :watering_frequency, :manual_watering_frequency)
    end
end
