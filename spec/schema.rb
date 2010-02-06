ActiveRecord::Schema.define(:version => 0) do
  create_table "traffic_lights", :force => true do |t|
    t.integer "state_id"
  end
end