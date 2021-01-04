require 'oystercard'
require 'journey'
require 'journeylog'
require 'station'

describe Oystercard do
  subject(:oystercard) { Oystercard.new() }
  context "balance" do
    it "is zero" do
      expect(subject.balance).to(eq(0))
    end
    it "check top_up method" do
      expect(subject).to(respond_to(:top_up).with(1).argument)
    end
    it "top-up" do
      top_up_value = 40
      past_balance = subject.balance
      new_balance = subject.top_up(top_up_value)
      expect(new_balance).to(eq(past_balance + top_up_value))
    end
    it "top-up limit" do
      top_up_value = Oystercard::BALANCE_LIMIT + 10
      expect {
        subject.top_up(top_up_value)
      }.to(raise_error("Deposit amount is over the balance limit!"))
    end
    it "check deducted method" do
      expect(subject).to(respond_to(:touch_out).with(1).argument)
    end
    it "deducted" do
      entry_station = Station.new(station_name="entry station", zone=1)
      exit_station = Station.new(station_name="exit station", zone=2)
      top_up_value = 10
      subject.top_up(top_up_value)
      subject.touch_in(entry_station)
      subject.touch_out(exit_station)
      past_journey = subject.journey_log.journeys[-1]
      fare = past_journey.fare()
      expect(subject.balance).to(eq(top_up_value - fare))
    end
    it "insufficient for touch in" do
      entry_station = double("entry_station")
      expect {
        subject.touch_in(entry_station)
      }.to(raise_error("Insufficient balance for trip!"))
    end
    it "deducted on touch out" do
      entry_station = Station.new("entry station", 1)
      exit_station = Station.new("exit station", 2)
      top_up_value = 20
      subject.top_up(top_up_value)
      subject.touch_in(entry_station)
      subject.touch_out(exit_station)
      past_journey = subject.journey_log.journeys[-1]
      fare = past_journey.fare()
      expect(subject.balance).to(eq(top_up_value - fare))
    end
  end
  context "state" do
    it "touched in" do
      entry_station = double("entry_station")
      subject = Oystercard.new(10)
      subject.touch_in(entry_station)
      expect(subject.in_journey?()).to(eq(true))
    end
    it "touched out" do
      exit_station = "exit_station"
      subject.top_up(20)
      subject.touch_in()
      subject.touch_out(exit_station)
      expect(subject.in_journey?()).to(eq(false))
    end
    it "in journey?" do
      expect(subject).to(respond_to(:in_journey?))
    end
    it "touched in after forgetting to touch out" do
      entry_station = Station.new("entry station", 1)
      other_entry_station = Station.new("other entry station", 2)
      exit_station = Station.new("exit station", 2)
      initial_balance = 20
      journey_cost = 0
      subject.top_up(initial_balance)
      subject.touch_in(entry_station)
      subject.touch_in(other_entry_station) # - PENALTY_FARE
      journey_cost += Oystercard::PENALTY_FARE
      subject.touch_out(exit_station) # - Journey fare
      past_journey = subject.journey_log.journeys[-1]
      fare = past_journey.fare()
      journey_cost += fare
      expect(subject.balance).to(eq(initial_balance - journey_cost))
    end
  end
  context "journey" do
    it "empty by default" do
      expect(subject.journey_log.journeys.length).to(eq(0))
    end
    it "is created" do
      subject = Oystercard.new(20)
      entry_station = Station.new("entry station", 3)
      exit_station = Station.new("exit station", 5)
      subject.touch_in(entry_station)
      subject.touch_out(exit_station)
      expect(subject.journey_log.journeys.length).to(eq(1))
    end
    it "same zone" do
      initial_balance = 20
      subject = Oystercard.new(initial_balance)
      entry_station = Station.new("entry station", 3)
      exit_station = Station.new("exit station", 3)
      subject.touch_in(entry_station)
      subject.touch_out(exit_station)
      past_journey = subject.journey_log.journeys[-1]
      fare = past_journey.fare()
      expect(fare).to(eq(1))
    end
    it "zone 1 - 2" do
      initial_balance = 20
      subject = Oystercard.new(initial_balance)
      entry_station = Station.new("entry station", 2)
      exit_station = Station.new("exit station", 1)
      subject.touch_in(entry_station)
      subject.touch_out(exit_station)
      past_journey = subject.journey_log.journeys[-1]
      fare = past_journey.fare()
      expect(fare).to(eq(2))
    end
    it "zone 3 - 5" do
      initial_balance = 20
      subject = Oystercard.new(initial_balance)
      entry_station = Station.new("entry station", 3)
      exit_station = Station.new("exit station", 4)
      subject.touch_in(entry_station)
      subject.touch_out(exit_station)
      past_journey = subject.journey_log.journeys[-1]
      fare = past_journey.fare()
      expect(fare).to(eq(3))
    end
  end
end
