module ActiveRecord
  class Enum
    extend ActiveRecord::Enumerations::OptionsHelper
    
    attr_reader :id, :name, :extra_columns
    class_attribute :label_method
    
    def initialize attrs = {}
      @id = attrs.delete(:id).to_i
      @name = attrs.delete(:name).to_s
      @extra_columns = attrs.reject { |k, _| [:enum_class, :on_style_not_matched].include?(k) }
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
    alias_method :eql?, :==
    
    def hash
      id.hash
    end
    
    def to_s
      try_labelize(self, :desc) || try_labelize(name, :titleize)
    end
    
    def to_sym
      name.to_sym
    end
    
    def self.enumeration *config, &block
      add_option config, :class_name => self
      define_enums_getter ActiveRecord::Enumerations::Factory.make_enums(*config, &block)
    end
    
    def self.[] name_or_id
      all.detect { |enum| enum == name_or_id }
    end
    class << self
      alias_method :find_by_id, :[]
    end
    
    def self.find_all_by_id ids, options = {}
      all.select { |enum| ids.include? enum.id }
    end
    
    def in? *enums
      enums.any? { |e| self == e }
    end
    
    private
    def self.define_enums_getter enums
      cattr_accessor :all
      self.all = enums
    end
    
    def try_labelize object, default_method
      object.respond_to?(label_method) && object.send(label_method) or object.respond_to?(default_method) && object.send(default_method)
    end
  end
end
