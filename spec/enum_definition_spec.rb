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
    
    it "can be created with a block" do
      define_model_class 'TrafficLight' do
        enum :state do
          red :rgb => 0xF00
          green :rgb => 0x0F0
        end
      end
      TrafficLight.states[0].should be_enum_with(:id => 1, :name => 'red', :rgb => 0xF00)
      TrafficLight.states[1].should be_enum_with(:id => 2, :name => 'green', :rgb => 0x0F0)
    end
    
    it "should provide method to access all enums ready to use in select helpers" do
      TrafficLight.states.map { |enum| [enum.id, enum.name] }.should == [[1, 'red'], [2, 'green'], [3, 'yellow']]
    end    
    
    it "class with several enums should be fine" do
      define_model_class 'Contact' do
        enum :contact_type, %w[client provider]
        enum :fiscal_risk, %w[low high]
      end
      Contact.contact_types.map(&:name).should == %w[client provider]
      Contact.fiscal_risks.map(&:name).should == %w[low high]
    end
  end
  
  context "options" do
    context ":label options" do
      it "should override default to_s of Enum" do
        define_traffic_light :state, %w[green red], :label => :upcase
        TrafficLight.new(:state => :green).state.to_s.should == 'GREEN'
        TrafficLight.new(:state => :red).state.to_s.should == 'RED'
      end      
      
      it "should work with blocks style" do
        define_model_class 'TrafficLight' do
          enum :state, :label => :upcase do
            green
          end
        end
        TrafficLight.new(:state => :green).state.to_s.should == 'GREEN'
      end

      it "should work with array of hashes style" do
        define_traffic_light :state, [{ :name => :red }, { :name => :green }], :label => :upcase
        TrafficLight.new(:state => :red).state.to_s.should == 'RED'
        TrafficLight.new(:state => :green).state.to_s.should == 'GREEN'
      end
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
end

describe "External enumerations" do
  before do
    define_model_class 'State', 'ActiveRecord::Enum' do
      enumeration do
        green :rgb => 0x0F0
        red :rgb => 0xF00
      end
    end    
  end
  
  it "should allow to define enumerations on it's own class" do
    define_model_class 'TrafficLight' do
      enum :state
    end
    TrafficLight.new(:state => :red).state.should be_enum_with(:name => 'red', :rgb => 0xF00, :id => 2)
  end

  it "should be posible to access all enums from withing the owner" do
    define_model_class 'TrafficLight' do
      enum :state
    end
    TrafficLight.states.should equal(State.all)
  end
  
  it "should accept :class_name options to override de class of the external enum" do
    define_model_class 'TrafficLight' do
      enum :state_on_weekdays, :class_name => 'State'
      enum :state_on_weekends, :class_name => 'State'
    end
    TrafficLight.state_on_weekdays.should equal(State.all)
    TrafficLight.state_on_weekends.should equal(State.all)
  end
end