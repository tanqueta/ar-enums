module ActiveRecord
  class Enum
    attr_reader :id, :name
    
    def initialize attrs = {}
      @id = attrs.delete(:id).to_i
      @name = attrs.delete(:name).to_s
      @label = attrs.delete(:label)
      define_extra_attributes_as_methods attrs
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
      @label ||= respond_to?(:desc) ? :desc : :titleize
      self.respond_to?(@label) ? self.send(@label) : self.name.send(@label)
    end
    
    def to_sym
      name.to_sym
    end
    
    def define_question_methods all_enums
      all_enums.each do |enum|
        meta_def("#{enum.name}?") { self == enum }
      end
    end
    
    def self.enumeration *config, &block
      values, options = extract_values_and_options config
      enums = create_enums values, options, &block
      define_enums_getter enums
    end
    
    def self.[] name_or_id
      all.detect { |enum| enum == name_or_id }
    end
    
    private
    def define_extra_attributes_as_methods attrs
      attrs.each do |method, value|
        meta_def(method) { value }
      end
    end    
    
    def self.create_enums values, options, &block
      enums = if block_given?
        create_enums_from_internal_block_style options, &block
      elsif values.any?
        create_enums_from_internal_array_of_values_or_array_of_hashes_style values, options
      end
      enums.each { |enum| enum.define_question_methods(enums) }
    end
    
    def self.create_enums_from_internal_block_style options, &block
      ArEnums::EnumBlock.new(options).instance_eval(&block)
    end
    
    def self.create_enums_from_internal_array_of_values_or_array_of_hashes_style values, options
      values.map { |value| ActiveRecord::Enum.create_from(value, values, options) }
    end
    
    def self.extract_values_and_options config
      if config.first.is_a?(Array)
        [config[0], config[1] || {}]
      else
        [[], config[0] || {}]
      end
    end
    
    def self.define_enums_getter enums
      cattr_accessor :all
      self.all = enums
    end
  end
end
