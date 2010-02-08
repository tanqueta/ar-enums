module ActiveRecord
  module Enumerations
    class Factory
      include OptionsHelper
      
      def self.make_enums *config, &block
        new.make_enums *config, &block
      end
    
      def make_enums *config, &block
        values, options = extract_values_and_options config
        options[:enum_class].label_method = options.delete(:label) || :desc
        create_enums(values, options, &block).tap do |enums|
          define_question_methods options[:enum_class], enums
          define_extra_columns_methods options[:enum_class], enums
        end
      end
    
      private
      def create_enums values, options, &block
        enums = if block_given?
          block_style options, &block
        elsif values.any?
          array_of_values_or_hashes_style values, options
        elsif options[:on_style_not_matched]
          options[:on_style_not_matched].call options
        end
      end
    
      def block_style options, &block
        EnumBlock.new(options).instance_eval(&block)
      end
    
      def array_of_values_or_hashes_style values, options
        values.map { |value| options[:enum_class].create_from(value, values, options) }
      end
      
      def define_question_methods enum_class, enums
        enums.each do |e|
          enum_class.class_eval %Q{
            def #{e.name}?
              self == :#{e.name}
            end
          }
        end
      end
      
      def define_extra_columns_methods enum_class, enums
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