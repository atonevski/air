class CreateMeasurement < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.date :day
      t.integer :parameter_id
      t.integer :station_id
      t.integer :count
      t.float :min
      t.float :max
      t.float :avg
      t.text :data
    end
    add_index :measurements, :parameter_id
    add_index :measurements, :station_id
  end
end
