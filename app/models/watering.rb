class Watering < ApplicationRecord
  belongs_to :plant
  validates :date, presence: true

  before_validation :set_fulfilled_status

  after_save_commit :update_watering_intervals
  after_destroy :update_watering_intervals

  after_save_commit :update_last_watering
  after_destroy :update_last_watering


  scope :fulfilled, -> { where(fulfilled: true) }
  scope :scheduled, -> { where(fulfilled: false) }

  # interval: integer # of days between this watering and the last watering for the same plant
  def interval
    if super.nil?
      set_interval
    else
      super
    end
  end

  def set_interval
    current = plant.waterings.index self
    if current > 0
      prev_watering = plant.waterings[current - 1]
      self.interval = (self.date.to_date - prev_watering.date.to_date).to_i
    else
      # this is the first watering logged for this plant
      self.interval = -1
    end
    self.interval if save
  end

  def interval_text
    if interval >= 0
      "#{interval} #{I18n.t 'time.days'}"
    else
      "n/a"
    end
  end

  def self.create_from_json(json)
    w = Watering.new do |w|
      w.id = json['id']
      w.plant_id = json['plant_id']
      w.date = json['date']
      w.notes = json['notes']
      w.created_at = json['created_at']
      w.updated_at = json['updated_at']
    end
    w.save
    w
  end
  private

  def set_fulfilled_status
    # If watering date is in the future, mark as not fulfilled
    self.fulfilled = date <= Date.today if date.present?
  end

  def update_watering_intervals
    # created or deleted or date changed
    if previous_changes[:id] || self.destroyed? || previous_changes[:date]
      later_waterings = plant.waterings.select {|w| w.date > self.date}
      later_waterings.each &:set_interval
    end
  #
  end

  def update_last_watering
    # byebug
    date = plant.waterings.fulfilled.order(:date).last&.date
    unless plant.date_last_watering == date
      plant.update date_last_watering: date
    end
    unless plant.last_watering == self
      plant.update last_watering: self
    end
  end
end
