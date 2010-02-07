module ActiveRecord
  module Enumerations
    class Factory
      include OptionsHelper
      
      attr_reader :enums
    
      def initialize on_style_not_matched = nil
        @on_style_not_matched = on_style_not_matched
      end
    
      def self.make_enums *config, &block
        new.make_enums *config, &block
      end
    
      def make_enums *config, &block
        values, options = extract_values_and_options config
        enums = create_enums values, options, &block
        enums.each { |enum| enum.define_question_methods(enums) }
      end
    
      private
      def create_enums values, options, &block
        enums = if block_given?
          block_style options, &block
        elsif values.any?
          array_of_values_or_hashes_style values, options
        elsif @on_style_not_matched
          @on_style_not_matched.call options
        end
      end
    
      def block_style options, &block
        EnumBlock.new(options).instance_eval(&block)
      end
    
      def array_of_values_or_hashes_style values, options
        values.map { |value| Enum.create_from(value, values, options) }
      end
    end
  end
end