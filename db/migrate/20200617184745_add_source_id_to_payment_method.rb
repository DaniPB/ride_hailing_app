class AddSourceIdToPaymentMethod < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_methods, :source_id, :string, null: false
  end
end
