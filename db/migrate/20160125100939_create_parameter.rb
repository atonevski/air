class CreateParameter < ActiveRecord::Migration
  def change
    create_table :parameters do |t|
      t.string :name
      t.text :mk
      t.string :unit
      t.string :short
      t.string :short_no_subscript
      t.text :levels
    end
    add_index :parameters, :name
  end
end
