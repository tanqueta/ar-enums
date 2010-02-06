require 'active_record'
require 'object_extensions'

module ActiveRecord
  class Enum
    attr_reader :id, :name
    
    def initialize attrs = {}
      @id = attrs[:id]
      @name = attrs[:name]
    end
    
    def == other
      id.to_s == other.to_s or name.to_s == other.to_s
    end
  end
end

module ArEnums
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  class EnumField
    attr_reader :name
    
    def initialize name
      @name = name.to_s
    end
    
    def enums_getter
      name.pluralize
    end
    
    def enums_setter
      "#{enums_getter}="
    end
    
    def foreign_key
      "#{name}_id"
    end
  end
  
  module ClassMethods
    def enum field_name, values
      field = EnumField.new field_name
      enums = create_enums values
      define_enums_getter field, enums      
      define_enum_getter_and_setter field, enums      
    end
    
    private
    def create_enums values
      values.map { |value| ActiveRecord::Enum.new(:id => values.index(value) + 1, :name => value) }
    end
    
    def define_enums_getter field, enums
      define_class_method(field.enums_getter) { enums }
    end
    
    def define_enum_getter_and_setter field, enums
      define_method field.name do
        enums.detect { |enum| enum.id == read_attribute(field.foreign_key) }    
      end                                                                       
      
      define_method "#{field.name}=" do |value|
        write_attribute field.foreign_key, enums.detect { |enum| enum == value }.try(:id)
      end
    end
  end
end

ActiveRecord::Base.send :include, ArEnums