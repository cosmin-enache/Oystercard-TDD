class Journey
  attr_reader :entry_station, :exit_station

  def initialize(entry_station=nil, exit_station=nil)
    set_entry(entry_station)
    set_exit(exit_station)
  end

  def complete?()
    if @entry_station != nil && exit_station != nil
      return true
    else
      return false
    end
  end

  def fare()
    entry_station_zone = @entry_station.zone
    exit_station_zone = @exit_station.zone
    if entry_station_zone == exit_station_zone
      return 1
    elsif between?(entry_station_zone, [1, 2]) and between?(exit_station_zone, [1, 2])
      return 2
    elsif between?(entry_station_zone, [3, 5]) and between?(exit_station_zone, [3, 5])
      return 3
    end
  end

  def set_entry(entry)
    @entry_station = entry
  end

  def set_exit(exit)
    @exit_station = exit
  end

  private

  def between?(zone, limits)
    if zone >= limits[0] and zone <= limits[1]
      return true
    end
    return false
  end

end
