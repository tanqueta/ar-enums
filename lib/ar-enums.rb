require 'active_record'
%w[metaprogramming_extensions options_helper base enum_block enum_field factory enum_definition].each do |f|
  require "ar_enums/#{f}"
end
