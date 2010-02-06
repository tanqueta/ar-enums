require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Enum" do
  it "default to_s should return name titleized" do
    ActiveRecord::Enum.new(:name => :green_color).to_s.should == 'Green Color'
  end
  
  it "should provide :to_sym method returning name as symbols" do
    ActiveRecord::Enum.new(:name => :green).to_sym.should == :green
  end
end