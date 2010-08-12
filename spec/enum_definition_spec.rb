require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Internal enumerations" do
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
  
  context "options" do
    it "should pass the options to the factory" do
      define_traffic_light :state, %w[green red], :label => :upcase
      TrafficLight.new(:state => :green).state.to_s.should == 'GREEN'
      TrafficLight.new(:state => :red).state.to_s.should == 'RED'
    end
  end
  
  context "question methods" do
    before do
      define_traffic_light :state, %w[green red]
    end
    
    it "should provide question method" do
      TrafficLight.new(:state => :green).state.should be_green
      TrafficLight.new(:state => :green).state.should_not be_red
      TrafficLight.new(:state => :red).state.should_not be_green
      TrafficLight.new(:state => :red).state.should be_red
    end
    
    it "should raise error if tested with inexistant enum" do
      lambda { TrafficLight.new(:state => :green).state.blue? }.should raise_error(NameError)
    end
    
    it "block style should also provide question method" do
      define_model_class 'TrafficLight' do
        enum :state do
          green
          red
        end
      end
      TrafficLight.new(:state => :green).state.should be_green
      TrafficLight.new(:state => :green).state.should_not be_red
    end
  end
  
  it "should be instances of a new subclass of Enum" do
    TrafficLight.states.first.should be_a(TrafficLight::State)
  end
end

describe "External enumerations" do
  before do
    define_model_class 'State', 'ActiveRecord::Enum' do
      enumeration do
        ca
        tx
      end
    end
    
    define_model_class 'Country' do
      enum :state
    end
    
    define_model_class 'TrafficLightState', 'ActiveRecord::Enum' do
      enumeration do
        green :rgb => 0x0F0
        red :rgb => 0xF00
      end
    end
    
    define_model_class 'TrafficLight' do
      enum :state, :class_name => 'TrafficLightState'
    end
  end
  
  context "enums creation" do
    it "should allow to define enumerations on it's own class" do
      TrafficLight.new(:state => :red).state.should be_enum_with(:name => 'red', :rgb => 0xF00, :id => 2)
    end

    it "should be posible to access all enums from withing the owner" do
      TrafficLight.states.should equal(TrafficLightState.all)
      Country.states.should equal(State.all)
    end

    it "should accept :class_name options to override de class of the external enum" do
      define_model_class 'TrafficLight' do
        enum :state_on_weekdays, :class_name => 'TrafficLightState'
        enum :state_on_weekends, :class_name => 'TrafficLightState'
      end
      TrafficLight.state_on_weekdays.should equal(TrafficLightState.all)
      TrafficLight.state_on_weekends.should equal(TrafficLightState.all)
    end    
    
    it "external enums should be instances of the subclass of Enum" do
      TrafficLightState.all.each { |s| s.should be_a(TrafficLightState) }
    end
    
    it "should be posible to define new methods in Enum subclass" do
      define_model_class 'State', 'ActiveRecord::Enum' do
        enumeration do
          green :factor => 1
          red :factor => 2
        end
        
        def double_factor() factor * 2 end
      end    
      State.all.map(&:double_factor).should == [2, 4]
    end 
    
    it "should not define new constant form enum class" do
      define_model_class 'TrafficLight' do
        enum :estado, :class_name => 'TrafficLightState'
      end
      expect { TrafficLight.const_get(:Estado) }.to raise_error NameError
    end   
  end
end