
class Oystercard
  attr_reader :balance, :entry_station, :journeys, :journey_log

  BALANCE_LIMIT = 90
  MINIMUM_FARE = 1
  PENALTY_FARE = 6

  def initialize(balance=0)
    @balance = balance
    @entry_station = nil
    @journey_log = JourneyLog.new()
  end

  def over_limit?(amount)
    if @balance + amount > BALANCE_LIMIT
      return true
    else
      return false
    end
  end

  def top_up(deposit_amount)
    if over_limit?(deposit_amount)
      raise "Deposit amount is over the balance limit!"
    else
      @balance += deposit_amount
      return @balance
    end
  end

  def touch_in(entry_station=nil)
    # penalty fare for forgetting to touch out
    if @journey_log.current_journey
      @balance -= PENALTY_FARE
    end
    if @balance >= MINIMUM_FARE
      @entry_station = entry_station
      @journey_log.start(entry_station)
    else
      raise "Insufficient balance for trip!"
    end
  end

  def touch_out(exit_station=nil)
    @journey_log.finish(exit_station)
    if @journey_log.current_journey.complete?()
      # deduct value based on station zone
      deduct(@journey_log.current_journey.fare())
    else
      deduct(PENALTY_FARE)
    end
    @journey_log.current_journey = nil
    @entry_station = nil
  end

  def in_journey?()
    if @entry_station
      return true
    else
      return false
    end
  end

  private

  def deduct(reduce_amount)
    @balance -= reduce_amount
    return @balance
  end
end
