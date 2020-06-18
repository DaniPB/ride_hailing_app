class AddStatusToTrips < ActiveRecord::Migration[6.0]
  def change
    add_column :trips, :status, :string, null: false, default: 'unstarted'
  end
end
