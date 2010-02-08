module ActiveRecord
  class Enum
    extend ActiveRecord::Enumerations::OptionsHelper
    
    attr_reader :id, :name, :extra_columns
    class_inheritable_accessor :label_method
    
    def initialize attrs = {}
      @id = attrs.delete(:id).to_i
      @name = attrs.delete(:name).to_s
      @extra_columns = attrs.reject { |k, _| k == :enum_class }
    end
    
    def self.create_from value, values, options
      required_attrs = case value
      when String, Symbol
        { :name => value }
      else
        value
      end
      required_attrs[:id] ||= values.index(value) + 1
      new options.merge(required_attrs)
    end
    
    def == other
      return id == other.id if other.is_a?(Enum)
      [id.to_s, name].include?(other.to_s)
    end
    
    def to_s
      self.respond_to?(label_method) ? self.send(label_method) : self.name.send(label_method)
    end
    
    def to_sym
      name.to_sym
    end
    
    def self.enumeration *config, &block
      add_option config, :enum_class => self
      define_enums_getter ActiveRecord::Enumerations::Factory.make_enums(*config, &block)
    end
    
    def self.[] name_or_id
      all.detect { |enum| enum == name_or_id }
    end
    
    private
    def self.define_enums_getter enums
      cattr_accessor :all
      self.all = enums
    end
  end
end
