require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Inline enumeration" do
  class TrafficLight < ActiveRecord::Base
    enum :state, %w[red green yellow]
  end

  it "getter should return an Enum" do
    s = TrafficLight.new(:state_id => 3).state
    s.should be_a(ActiveRecord::Enum)
    s.name.should == 'yellow'
    s.id.should == 3
  end
  
  it "should store ordinal by default as foreign key" do
    TrafficLight.new(:state => :green).state_id.should == 2
  end
  
  it "should store nil if enum doesn't exists" do
    TrafficLight.new(:state => :black).state_id.should be_nil
  end
  
  it "should allow to set enum with symbol" do
    TrafficLight.new(:state => :red).state.should == :red
    TrafficLight.new(:state => :green).state.should == :green
  end
  
  it "should allow to set enum with string" do
    TrafficLight.new(:state => 'red').state.should == :red
    TrafficLight.new(:state => 'green').state.should == :green
  end

  it "should allow to set enum with ordinal" do
    TrafficLight.new(:state_id => 1).state.should == :red
    TrafficLight.new(:state_id => 2).state.should == :green
  end
  
  it "should provide method to access all enums ready to use in select helpers" do
    TrafficLight.states.map { |enum| [enum.id, enum.name] }.should == [[1, 'red'], [2, 'green'], [3, 'yellow']]
  end
end
