$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'ar-enums'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  config.before :suite do
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    load(File.dirname(__FILE__) + "/schema.rb")
  end
  
  def define_model_class(name = "TestClass", parent_class_name = "ActiveRecord::Base", &block)
  	Object.send(:remove_const, name) rescue nil
  	eval("class #{name} < #{parent_class_name}; end", TOPLEVEL_BINDING)
  	klass = eval(name, TOPLEVEL_BINDING)
  	klass.class_eval(&block) if block_given?
  end
end

Spec::Matchers.define :be_enum_with do |expected_attrs|
  match do |enum|
    enum.should be_a(ActiveRecord::Enum)
    expected_attrs.each do |atrib, expected_value|
      enum.send(atrib).should == expected_value
    end
  end
end
