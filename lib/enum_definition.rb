module ArEnums
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    def enum field_name, *config, &block
      values, options = extract_values_and_options config
      field = EnumField.new field_name
      enums = create_enums field, values, options, &block
      define_enums_getter field, enums      
      define_enum_getter_and_setter field, enums      
    end
    
    private
    def extract_values_and_options config
      if config.first.is_a?(Array)
        [config[0], config[1] || {}]
      else
        [[], config.first || {}]
      end
    end
    
    def create_enums field, values, options, &block
      enums = if block_given?
        EnumBlock.new(options).instance_eval(&block)
      elsif values.any?
        values.map { |value| ActiveRecord::Enum.create_from(value, values, options) }
      else
        field.external_class(options).all
      end
      enums.each { |enum| enum.define_question_methods(enums) }
    end
    
    def define_enums_getter field, enums
      define_class_method(field.enums_getter) { enums }
    end
    
    def define_enum_getter_and_setter field, enums
      define_method field.name do
        enums.detect { |enum| enum.id == read_attribute(field.foreign_key) }    
      end                                                                       
      
      define_method "#{field.name}=" do |value|
        write_attribute field.foreign_key, enums.detect { |enum| enum == value }.try(:id)
      end
    end
  end
end

ActiveRecord::Base.send :include, ArEnums