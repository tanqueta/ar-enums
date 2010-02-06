require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Enum" do
  context "API" do
    it "default to_s should return name titleized" do
      ActiveRecord::Enum.new(:name => :green_color).to_s.should == 'Green Color'
    end

    it "should provide :to_sym method returning name as symbols" do
      ActiveRecord::Enum.new(:name => :green).to_sym.should == :green
    end
  end
  
  context "DSL for external enums" do
    before do
      define_model_class 'Color', 'ActiveRecord::Enum' do
        enumeration do
          red :rgb => 0xF00
          green :rgb => 0x0F0
        end
      end    

      define_model_class 'State', 'ActiveRecord::Enum' do
        enumeration do
          on
          off
        end
      end    
    end
    
    it "should provide :all method to access the enums" do
      Color.all[0].should be_enum_with(:name => 'red', :rgb => 0xF00)
      Color.all[1].should be_enum_with(:name => 'green', :rgb => 0x0F0)
      State.all[0].should be_enum_with(:name => 'on', :id => 1)
      State.all[1].should be_enum_with(:name => 'off', :id => 2)
    end
  end
end