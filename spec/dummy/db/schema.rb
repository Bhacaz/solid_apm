# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_06_08_021940) do
  create_table "solid_apm_spans", force: :cascade do |t|
    t.string "uuid", null: false
    t.integer "transaction_id", null: false
    t.integer "sequence", null: false
    t.datetime "timestamp", null: false
    t.string "name"
    t.string "type"
    t.string "subtype"
    t.string "summary"
    t.datetime "end_time"
    t.float "duration"
    t.json "stacktrace"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["timestamp"], name: "index_solid_apm_spans_on_timestamp", order: :desc
    t.index ["transaction_id"], name: "index_solid_apm_spans_on_transaction_id"
    t.index ["uuid"], name: "index_solid_apm_spans_on_uuid", unique: true
  end

  create_table "solid_apm_transactions", force: :cascade do |t|
    t.string "uuid", null: false
    t.datetime "timestamp", null: false
    t.string "type", null: false
    t.string "name"
    t.datetime "end_time", null: false
    t.float "duration"
    t.integer "unix_minute"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_solid_apm_transactions_on_name"
    t.index ["timestamp"], name: "index_solid_apm_transactions_on_timestamp", order: :desc
    t.index ["type"], name: "index_solid_apm_transactions_on_type"
    t.index ["uuid"], name: "index_solid_apm_transactions_on_uuid", unique: true
  end

  add_foreign_key "solid_apm_spans", "solid_apm_transactions", column: "transaction_id"
end
