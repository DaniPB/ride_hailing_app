class CreatePaymentMethods < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_methods do |t|
      t.string :type, null: false
      t.string :token, null: false
      t.timestamps null: false
    end
  end
end
