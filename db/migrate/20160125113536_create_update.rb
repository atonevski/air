class CreateUpdate < ActiveRecord::Migration
  def change
    create_table :updates do |t|
      t.date :day
      t.integer :parameter_id
      t.integer :station_id
    end
    add_index :updates, :parameter_id
    add_index :updates, :station_id
  end
end
