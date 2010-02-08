module ActiveRecord
  module Enumerations
    def self.included(base)
      base.send :extend, ClassMethods
    end
  
    module ClassMethods
      include ActiveRecord::Enumerations::OptionsHelper
      
      def enum field_name, *config, &block
        field = EnumField.new field_name
        enum_class = Class.new Enum
        const_set field.name.camelize, enum_class
        add_option config, :enum_class => enum_class
        # TODO refactorizar este on_style a option
        enums = Factory.new(on_style_not_matched_asume_external_style(field)).make_enums *config, &block
        define_enums_getter field, enums
        define_enum_getter_and_setter field, enums      
      end
    
      private
      def on_style_not_matched_asume_external_style field
        lambda { |options| field.external_class(options).all }
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
end

ActiveRecord::Base.send :include, ActiveRecord::Enumerations