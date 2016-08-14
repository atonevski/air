class CreateRegion < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.string :name
      t.text :mk
    end
    add_index :regions, :name
  end
end
