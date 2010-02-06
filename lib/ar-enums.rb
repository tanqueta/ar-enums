require 'active_record'
Dir["#{File.dirname(__FILE__)}/*.rb"].reject { |f| f.include?(File.basename(__FILE__)) }.each { |f| require f }
