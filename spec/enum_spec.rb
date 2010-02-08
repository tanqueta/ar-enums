require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Enum" do
  it "should provide :to_sym method returning name as symbols" do
    ActiveRecord::Enum.new(:name => :green).to_sym.should == :green
  end
  
  it "should store extra columns as a hash without the :enum_class that is passed from other classes" do
    ActiveRecord::Enum.new(:name => :green, :factor => 1.5, :enum_class => Class.new).extra_columns.should == { :factor => 1.5 }
  end

  context "External enums" do
    before do
      define_model_class 'Color', 'ActiveRecord::Enum' do
        enumeration do
          red :rgb => 0xF00
          green :rgb => 0x0F0
        end
      end    

      define_model_class 'State', 'ActiveRecord::Enum' do
        enumeration do
          on :id => 80
          off :id => 90
        end
      end    
    end
    
    it "should provide :all method to access the enums" do
      Color.all[0].should be_enum_with(:name => 'red', :rgb => 0xF00)
      Color.all[1].should be_enum_with(:name => 'green', :rgb => 0x0F0)
      State.all[0].should be_enum_with(:name => 'on', :id => 80)
      State.all[1].should be_enum_with(:name => 'off', :id => 90)
    end
    
    it "should provide [] method to access the enums" do
      Color[:red].should be_enum_with(:name => 'red')
      Color['green'].should be_enum_with(:name => 'green')
      Color[2].should be_enum_with(:name => 'green')
    end
  end
end