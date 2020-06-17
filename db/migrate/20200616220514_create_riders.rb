class CreateRiders < ActiveRecord::Migration[6.0]
  def change
    create_table :riders do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone, null: false
      t.string :email, null: false
      t.timestamps null: false

      t.belongs_to :payment_method
    end
  end
end
