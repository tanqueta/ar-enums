require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def define_model_class(name = "TestClass", parent_class_name = "ActiveRecord::Base", &block)
	Object.send(:remove_const, name) rescue nil
	eval("class #{name} < #{parent_class_name}; end", TOPLEVEL_BINDING)
	klass = eval(name, TOPLEVEL_BINDING)
	klass.class_eval(&block) if block_given?
end

def define_traffic_light *options
  define_model_class 'TrafficLight' do
    enum *options
  end
end

describe "Inline enumeration" do
  before do
    define_traffic_light :state, %w[red green yellow]
  end
  
  context "getter and setter" do
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
  end
  
  context "class method getter" do
    it "should provide method to access all enums ready to use in select helpers" do
      TrafficLight.states.map { |enum| [enum.id, enum.name] }.should == [[1, 'red'], [2, 'green'], [3, 'yellow']]
    end    
  end
  
  context "options" do
    before do
      define_traffic_light :state, %w[green], :label => :upcase
    end

    it "should provide :to_s option to override default to_s of Enum" do
      TrafficLight.new(:state => :green).state.to_s.should == 'GREEN'
    end
  end
end

describe "Enum" do
  it "default to_s should return name titleized" do
    ActiveRecord::Enum.new(:name => :green_color).to_s.should == 'Green Color'
  end
end