# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_17_223908) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "drivers", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone", null: false
    t.string "email", null: false
    t.string "status", default: "occupated", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string "method_type", default: "CARD", null: false
    t.string "token", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "rider_id"
    t.string "source_id", null: false
    t.index ["rider_id"], name: "index_payment_methods_on_rider_id"
  end

  create_table "riders", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone", null: false
    t.string "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "payment_method_id"
    t.index ["payment_method_id"], name: "index_riders_on_payment_method_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "payment_method_id"
    t.bigint "trip_id"
    t.string "pay_reference", null: false
    t.index ["payment_method_id"], name: "index_transactions_on_payment_method_id"
    t.index ["trip_id"], name: "index_transactions_on_trip_id"
  end

  create_table "trips", force: :cascade do |t|
    t.hstore "from", null: false
    t.hstore "to", null: false
    t.float "price", default: 0.0, null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "rider_id"
    t.bigint "driver_id"
    t.index ["driver_id"], name: "index_trips_on_driver_id"
    t.index ["rider_id"], name: "index_trips_on_rider_id"
  end

end
