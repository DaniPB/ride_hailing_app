class CreateTrips < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    create_table :trips do |t|
      t.hstore :from, null: false
      t.hstore :to, null: false
      t.float :price, null: false, default: 0.0
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.timestamps null: false

      t.belongs_to :rider
      t.belongs_to :driver
    end
  end
end
