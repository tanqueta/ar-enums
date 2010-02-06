require 'active_record'
Dir['lib/*.rb'].reject { |f| f.include?(File.basename(__FILE__)) }.each { |f| require f }
