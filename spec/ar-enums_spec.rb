require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Inline enumeration" do
  def define_traffic_light *options
    define_model_class 'TrafficLight' do
      enum *options
    end
  end

  before do
    define_traffic_light :state, %w[red green yellow]
  end
  
  context "getter and setter" do
    it "getter should return an Enum" do
      TrafficLight.new(:state_id => 3).state.should be_enum_with(:id => 3, :name => 'yellow')
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
  end
  
  context "enums creation" do
    it "can be created with an array of hashes with ids" do
      define_traffic_light :state, [{ :id => 2, :name => :red }, { :id => 1, :name => :green }]
      TrafficLight.states[0].should be_enum_with(:id => 2, :name => 'red')
      TrafficLight.states[1].should be_enum_with(:id => 1, :name => 'green')
    end
    
    it "can be created with an array of hashes without ids (should be generated)" do
      define_traffic_light :state, [{ :name => :red }, { :name => :green }]
      TrafficLight.states[0].should be_enum_with(:id => 1, :name => 'red')
      TrafficLight.states[1].should be_enum_with(:id => 2, :name => 'green')
    end
    
    it "should provide method to access all enums ready to use in select helpers" do
      TrafficLight.states.map { |enum| [enum.id, enum.name] }.should == [[1, 'red'], [2, 'green'], [3, 'yellow']]
    end    
  end
  
  context "options" do
    it "should provide :to_s option to override default to_s of Enum" do
      define_traffic_light :state, %w[green], :label => :upcase
      TrafficLight.new(:state => :green).state.to_s.should == 'GREEN'
    end
    
    it "should provide a way to add another columns to the enums" do
      define_traffic_light :state, [
        { :name => :red, :factor => 1.5, :stop_traffic => true },
        { :name => :green, :factor => 2.5, :stop_traffic => false }
      ]
      TrafficLight.new(:state => :red).state.factor.should == 1.5
      TrafficLight.new(:state => :green).state.factor.should == 2.5
      TrafficLight.new(:state => :red).state.stop_traffic.should be_true
      TrafficLight.new(:state => :green).state.stop_traffic.should be_false
    end
  end
end

describe "Enum" do
  it "default to_s should return name titleized" do
    ActiveRecord::Enum.new(:name => :green_color).to_s.should == 'Green Color'
  end
end