class CreateSolidCacheSchema < ActiveRecord::Migration[8.0]
  def up
    load Rails.root.join("db/cache_schema.rb")
  end

  def down
    drop_table :solid_cache_entries
  end
end
