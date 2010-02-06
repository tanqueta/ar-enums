module ActiveRecord
  class Enum
    attr_reader :id, :name
    
    def initialize attrs = {}
      @id = attrs.delete(:id).to_i
      @name = attrs.delete(:name).to_s
      @label_method = attrs.delete(:label) || :titleize
      define_extra_attributes_as_methods attrs
    end
    
    def self.create_from value, values, options
      new case value
      when String, Symbol
        options.merge :id => values.index(value) + 1, :name => value
      when Hash
        value[:id] ||= values.index(value) + 1
        value
      end
    end
    
    def == other
      return id == other.id if other.is_a?(Enum)
      [id.to_s, name].include?(other.to_s)
    end
    
    def to_s
      name.send @label_method
    end
    
    def to_sym
      name.to_sym
    end
    
    def define_question_methods all_enums
      all_enums.each do |enum|
        meta_def("#{enum.name}?") { self == enum }
      end
    end
    
    private
    def define_extra_attributes_as_methods attrs
      attrs.each do |method, value|
        meta_def(method) { value }
      end
    end    
  end
end
