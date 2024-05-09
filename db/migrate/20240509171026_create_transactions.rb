class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.string :uuid, index: { unique: true }, null: false
      t.datetime :timestamp, index: { order: :desc }, null: false # start_time
      t.string :type, index: true, null: false
      t.string :name, index: true
      # t.integer :status
      # t.string :method
      # t.string :query_params
      t.json :metadata
      t.datetime :end_time
      t.integer :duration

      t.timestamps
    end
  end
end
