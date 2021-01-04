
class JourneyLog
  attr_reader :journeys, :current_journey
  attr_accessor :current_journey

  def initialize()
    @journeys = []
    @current_journey = nil
  end

  def start(entry_station)
    @current_journey = Journey.new()
    @current_journey.set_entry(entry_station)
  end

  def finish(exit_station)
    @current_journey.set_exit(exit_station)
    @journeys << @current_journey
  end
end
