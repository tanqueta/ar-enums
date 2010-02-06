require 'active_record'
require 'metaprogramming_extensions'

module ActiveRecord
  class Enum
    attr_reader :id, :name
    
    def initialize attrs = {}
      @id = attrs.delete(:id).to_i
      @name = attrs.delete(:name).to_s
      @label_method = attrs.delete(:label) || :titleize
      attrs.each do |method, value|
        meta_def(method) { value }
      end
    end
    
    def self.create_from value, values, options
      new case value
      when String, Symbol
        options.merge :id => values.index(value) + 1, :name => value
      when Hash
        value[:id] ||= values.index(value) + 1
        value
      end
    end
    
    def == other
      [id.to_s, name].include?(other.to_s)
    end
    
    def to_s
      name.send @label_method
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
    def enum field_name, values, options = {}
      field = EnumField.new field_name
      enums = create_enums values, options
      define_enums_getter field, enums      
      define_enum_getter_and_setter field, enums      
    end
    
    private
    def create_enums values, options
      values.map { |value| ActiveRecord::Enum.create_from(value, values, options) }
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