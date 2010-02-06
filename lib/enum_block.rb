module ArEnums
  class EnumBlock    
    def initialize options = {}
      @enums = []
      @last_id = 0
      @options = options
    end
    
    def method_missing method, args = {}
      @enums << ActiveRecord::Enum.new(@options.merge(args).merge(:id => @last_id += 1, :name => method))
    end
  end
end