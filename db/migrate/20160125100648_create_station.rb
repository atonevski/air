class CreateStation < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.string :name
      t.text :mk
      t.integer :region_id
    end
    add_index :stations, :name
    add_index :stations, :region_id
  end
end
