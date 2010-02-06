module ArEnums
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
end