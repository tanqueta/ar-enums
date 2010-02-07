module ActiveRecord
  module Enumerations
    module OptionsHelper
      def add_option config, option
        new_config = if config.first.is_a?(Array)
          [config[0], (config[1] || {}).merge(option)]
        else
          [(config[0] || {}).merge(option)]
        end
        config.replace new_config
      end
      
      def extract_values_and_options config
        if config.first.is_a?(Array)
          [config[0], config[1] || {}]
        else
          [[], config[0] || {}]
        end
      end
    end
  end
end