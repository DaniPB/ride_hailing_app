class CreatePaymentMethods < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_methods do |t|
      t.string :method_type, null: false, default: "CARD"
      t.string :token, null: false
      t.timestamps null: false

      t.belongs_to :rider
    end
  end
end
