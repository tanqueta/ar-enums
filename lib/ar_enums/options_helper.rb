module ArEnums
  module OptionsHelper
    def add_option config, option
      new_config = if config.first.is_a?(Array)
        [config[0], (config[1] || {}).merge(option)]
      else
        [(config[0] || {}).merge(option)]
      end
      config.replace new_config
    end
    alias_method :add_options, :add_option
    
    def extract_values_and_options config
      if config.first.is_a?(Array)
        [config[0], config[1] || {}]
      else
        [[], config[0] || {}]
      end
    end
  end
end