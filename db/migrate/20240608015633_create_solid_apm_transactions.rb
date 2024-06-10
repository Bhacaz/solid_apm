class CreateSolidApmTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_apm_transactions do |t|
      t.string :uuid, index: { unique: true }, null: false
      t.datetime :timestamp, index: { order: :desc }, null: false # start_time
      t.string :type, index: true, null: false
      t.string :name, index: true
      t.datetime :end_time, null: false
      t.float :duration # in ms
      t.integer :unix_minute
      t.json :metadata

      t.timestamps
    end
  end
end
