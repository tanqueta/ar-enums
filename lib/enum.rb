module ActiveRecord
  class Enum
    attr_reader :id, :name
    
    def initialize attrs = {}
      @id = attrs.delete(:id).to_i
      @name = attrs.delete(:name).to_s
      @label_method = attrs.delete(:label) || :titleize
      attrs.each do |method, value|
        meta_def(method) { value }
      end
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
      [id.to_s, name].include?(other.to_s)
    end
    
    def to_s
      name.send @label_method
    end
  end
end
