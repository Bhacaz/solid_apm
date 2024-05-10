class CreateSpans < ActiveRecord::Migration[7.1]
  def change
    create_table :spans do |t|
      t.string :uuid, index: { unique: true }, null: false
      t.references :transaction, null: false, foreign_key: { to_table: :transactions }
      t.references :parent, foreign_key: false
      t.integer :sequence, null: false
      t.datetime :timestamp, index: { order: :desc }, null: false # start_time
      t.string :name
      t.string :type
      t.string :subtype
      t.string :summary
      t.datetime :end_time
      t.float :duration
      t.json :caller

      t.timestamps
    end
  end
end
