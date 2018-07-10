require 'ar-enums'

ActiveRecord::Migration.verbose = false

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }

  config.before :suite do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
    load(File.dirname(__FILE__) + "/schema.rb")
  end

  def define_model_class(name = "TestClass", parent_class_name = "ActiveRecord::Base", &block)
  	ActiveSupport::Dependencies.send :remove_const, name rescue nil
  	eval("class #{name} < #{parent_class_name}; end", TOPLEVEL_BINDING)
  	klass = eval(name, TOPLEVEL_BINDING)
  	klass.class_eval(&block) if block_given?
  end
end

RSpec::Matchers.define :be_enum_with do |expected_attrs|
  match do |enum|
    enum.should be_a(ArEnums::Base)
    expected_attrs.each do |atrib, expected_value|
      enum.send(atrib).should == expected_value
    end
  end
end

