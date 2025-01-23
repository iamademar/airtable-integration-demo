class CreateSolidCableSchema < ActiveRecord::Migration[8.0]
  def up
    load Rails.root.join("db/cable_schema.rb")
  end

  def down
    drop_table :solid_cable_messages
  end
end
