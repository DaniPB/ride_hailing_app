class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.timestamps null: false

      t.belongs_to :payment_method
      t.belongs_to :trip
    end
  end
end
