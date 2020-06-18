class AddPayReferenceToTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :transactions, :pay_reference, :string, null: false
  end
end
