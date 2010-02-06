module ArEnums
  class EnumBlock    
    def initialize options = {}
      @enums = []
      @last_id = 0
      @options = options
    end
    
    def method_missing method, args = {}
      attrs = @options.merge(args).merge(:name => method)
      attrs[:id] ||= @last_id += 1
      @enums << ActiveRecord::Enum.new(attrs)
    end
  end
end