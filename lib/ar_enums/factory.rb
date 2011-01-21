module ActiveRecord
  module Enumerations
    class Factory
      extend OptionsHelper
      
      def self.make_enums *config, &block
        values, options = extract_values_and_options config
        new(values, options, &block).make_enums
      end
      
      def initialize values, options, &block
        @values, @options, @block = values, options, block
        @active_record = @options.delete :active_record
        @field = @options.delete :field
        @class_name = @options.delete(:class_name) || @field.name.camelize
        @label_method = @options.delete(:label) || :desc
      end
    
      def make_enums
        enum_class.label_method = @label_method
        create_enums.tap do |enums|
          define_question_methods enums
          define_extra_columns_methods enums
        end
      end
      
      def enum_class
        @enum_class ||= eval_external_class || create_inner_enum_class
      end
    
      private      
      def eval_external_class
        @class_name.is_a?(String) || @class_name.is_a?(Symbol) ? @active_record.send(:compute_type, @class_name) : @class_name
      rescue NameError
        nil
      end
      
      def create_inner_enum_class
        @active_record.const_set @class_name, Class.new(Enum)
      end
      
      def create_enums
        if @block
          block_style
        elsif @values.any?
          array_of_values_or_hashes_style
        else
          enum_class.all
        end
      end
    
      def block_style 
        EnumBlock.new(enum_class, @options).instance_eval(&@block)
      end
    
      def array_of_values_or_hashes_style 
        @values.map { |value| enum_class.create_from(value, @values, @options) }
      end
      
      def define_question_methods enums
        enums.each do |e|
          enum_class.class_eval %Q{
            def #{e.name}?
              self == :#{e.name}
            end
          }
        end
      end
      
      def define_extra_columns_methods enums
        extra_columns_names = enums.map(&:extra_columns).map(&:keys).flatten.uniq
        extra_columns_names.each do |ecn|
          enum_class.class_eval %Q{
            def #{ecn}
              extra_columns[:#{ecn}]
            end
          }
        end
      end
    end
  end
end