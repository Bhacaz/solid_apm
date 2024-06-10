# This migration comes from solid_apm (originally 20240608021940)
class CreateSolidApmSpans < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_apm_spans do |t|
      t.string :uuid, index: { unique: true }, null: false
      t.references :transaction, null: false, foreign_key: { to_table: :solid_apm_transactions }
      t.integer :sequence, null: false
      t.datetime :timestamp, index: { order: :desc }, null: false # start_time
      t.string :name
      t.string :type
      t.string :subtype
      t.string :summary
      t.datetime :end_time
      t.float :duration
      t.json :stacktrace

      t.timestamps
    end
  end
end
