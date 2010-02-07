module ActiveRecord
  module Enumerations
    class EnumBlock    
      def initialize options = {}
        @enums = []
        @last_id = 0
        @options = options
        @options[:enum_class] ||= Enum # TODO esto no seria necesario despues de usar siempre subclases de Enum
      end
    
      def method_missing method, args = {}
        attrs = @options.merge(args).merge(:name => method)
        attrs[:id] ||= @last_id += 1
        @enums << @options[:enum_class].new(attrs)
      end
    end
  end
end