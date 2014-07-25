module ArEnums
  class EnumBlock    
    def initialize enum_class, options = {}
      @enums = []
      @last_id = 0
      @enum_class = enum_class
      @options = options
    end
  
    def method_missing method, args = {}
      attrs = @options.merge(args).merge(:name => method)
      attrs[:id] ||= @last_id += 1
      @enums << @enum_class.new(attrs)
    end
  end
end