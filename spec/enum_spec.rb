require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Enum" do
  context "label" do
    it "default to_s should return name titleized if desc is not provided" do
      ActiveRecord::Enum.new(:name => :green_color).to_s.should == 'Green Color'
    end

    it "default to_s should return desc if provided" do
      ActiveRecord::Enum.new(:name => :green, :desc => 'Verde').to_s.should == 'Verde'
    end
    
    it "should allow to specify :label option to use other field as to_s" do
      ActiveRecord::Enum.new(:name => :green, :descripcion => 'Verde', :label => :descripcion).to_s.should == 'Verde'      
    end    
  end

  context "other methods" do
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
  end
end