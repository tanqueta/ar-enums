require 'ar-enums'

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
load(File.dirname(__FILE__) + "/../spec/schema.rb")

class TrafficLight < ActiveRecord::Base
  enum :state, %w[red green yellow]
end

tl = TrafficLight.new(state: :green)
p tl.state      # => #<TrafficLight::State @name="green", @id=2>
p tl.state_id   # => 2
p TrafficLight.states.map(&:to_s)

# class TrafficLight < ActiveRecord::Base
#   enum :state, [
#     { name: :red, stop_traffic: true, rgb: 0xF00 },
#     { name: :green, stop_traffic: false, rgb: 0x0F0 }
#   ]
# end
#
# tl = TrafficLight.new(state: :green)
# p tl.state_id       # => 2
# p tl.state.stop_traffic   # => false
# p tl.state.rgb            # => 0x0F0
