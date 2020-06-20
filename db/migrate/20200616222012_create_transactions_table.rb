class CreateTransactionsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.string :pay_reference, null: false
      t.timestamps null: false

      t.belongs_to :payment_method
      t.belongs_to :trip
    end
  end
end
