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
end
