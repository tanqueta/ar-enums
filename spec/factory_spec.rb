require File.dirname(__FILE__) + '/spec_helper'

describe "Enums creation styles" do
  context "array of values style" do
    it "should generate ids" do
      enums = ArEnums::Factory.make_enums %w[red green blue]
      enums[0].should be_enum_with(:id => 1, :name => 'red')
      enums[1].should be_enum_with(:id => 2, :name => 'green')
      enums[2].should be_enum_with(:id => 3, :name => 'blue')
    end
    
    it ":label options should override default to_s" do
      enums = ArEnums::Factory.make_enums %w[green red], :label => :upcase
      enums.map(&:to_s).should == %w[GREEN RED]
    end      
  end
  
  context "array of hashes style" do
    it "should accept ids if provided" do
      enums = ArEnums::Factory.make_enums [{ :id => 20, :name => :red }, { :id => 10, :name => :green }]
      enums[0].should be_enum_with(:id => 20, :name => 'red')
      enums[1].should be_enum_with(:id => 10, :name => 'green')
    end
    
    it "should generate ids if not provided" do
      enums = ArEnums::Factory.make_enums [{ :name => :red }, { :name => :green }]
      enums[0].should be_enum_with(:id => 1, :name => 'red')
      enums[1].should be_enum_with(:id => 2, :name => 'green')
    end

    it "default to_s should be :desc column" do
      enums = ArEnums::Factory.make_enums [{ :name => :red, :desc => 'Rojo' }, { :name => :green, :desc => 'Verde' }]
      enums.map(&:to_s).should == %w[Rojo Verde]
    end      
    
    it ":label options can be a method to call on name" do
      enums = ArEnums::Factory.make_enums [{ :name => :red }, { :name => :green }], :label => :upcase
      enums.map(&:to_s).should == %w[RED GREEN]
    end   
       
    it ":label option can be a enum column" do
      enums = ArEnums::Factory.make_enums [{ :name => :red, :title => 'Rojo' }, { :name => :green, :title => 'Verde' }], :label => :title
      enums.map(&:to_s).should == %w[Rojo Verde]
    end      
  end
  
  context "block style" do
    it "can be created with a block" do
      enums = ArEnums::Factory.make_enums do
        red :rgb => 0xF00
        green :rgb => 0x0F0
      end
      enums[0].should be_enum_with(:id => 1, :name => 'red', :rgb => 0xF00)
      enums[1].should be_enum_with(:id => 2, :name => 'green', :rgb => 0x0F0)
    end    
    
    it "should accept :label option" do
      enums = ArEnums::Factory.make_enums :label => :title do
        red :title => 'Rojo'
        green :title => 'Verde'
      end
      enums.map(&:to_s).should == %w[Rojo Verde]
    end
  end
end
