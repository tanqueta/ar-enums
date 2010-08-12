module ActiveRecord
  module Enumerations
    def self.included(base)
      base.send :extend, ClassMethods
    end
  
    module ClassMethods
      include ActiveRecord::Enumerations::OptionsHelper
      
      def enum field_name, *config, &block
        field = EnumField.new field_name
        add_option config, :field => field, :active_record => self
        enums = Factory.make_enums *config, &block
        define_enums_getter field, enums
        define_enum_getter_and_setter field, enums      
      end
    
      private
      def asume_external_style field
        lambda { |options| external_class(field, options).all }
      end
      
      def external_class field, options = {}
        compute_type options.delete(:class_name) || field.name.camelize
      end
    
      def define_enums_getter field, enums
        meta_def(field.enums_getter) { enums }
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