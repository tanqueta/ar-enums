require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe "Enum" do
  it "should provide :to_sym method returning name as symbols" do
    ArEnums::Base.new(name: :green).to_sym.should == :green
  end

  it "should store extra columns as a hash without the :enum_class that is passed from other classes" do
    ArEnums::Base.new(name: :green, factor: 1.5, enum_class: Class.new).extra_columns.should == { factor: 1.5 }
  end

  context "External enums" do
    before do
      define_model_class 'Color', 'ArEnums::Base' do
        enumeration do
          red rgb: 0xF00
          green rgb: 0x0F0
          blue rgb: 0x00F
        end
      end

      define_model_class 'StateClass', 'ArEnums::Base' do
        enumeration do
          on id: 80
          off id: 90
        end
      end
    end

    it "should provide :all method to access the enums" do
      Color.all[0].should be_enum_with(name: 'red', rgb: 0xF00)
      Color.all[1].should be_enum_with(name: 'green', rgb: 0x0F0)
      StateClass.all[0].should be_enum_with(name: 'on', id: 80)
      StateClass.all[1].should be_enum_with(name: 'off', id: 90)
    end

    it "should provide [] method to access the enums" do
      Color[:red].should be_enum_with(name: 'red')
      Color['green'].should be_enum_with(name: 'green')
      Color[2].should be_enum_with(name: 'green')
    end
  end

  context "finders" do
    it "find_all_by_id" do
      Color.find_all_by_id([1, 2, 3, 4]).should == Color.all
      Color.find_all_by_id([1, 3]).should == [:red, :blue]
      Color.find_all_by_id([]).should == []
    end
  end

  it "in? should check if == to any" do
    define_model_class 'Color', 'ArEnums::Base' do
      enumeration do
        red rgb: 0xF00
        green rgb: 0x0F0
        blue rgb: 0x00F
      end
    end

    Color[:red].should be_in :red, :blue
    Color[:red].should be_in :green, :red, :blue
    Color[:red].should be_in Color[:red]
    Color[:red].should_not be_in :blue
  end

  it "should work with sets" do
    Set.new([Color[:red]]).intersection(Set.new([Color[:red].dup])).size.should == 1
  end

  it "should be sortable" do
    [Color[:green], Color[:red]].sort.should == [Color[:red], Color[:green]]
  end

end
