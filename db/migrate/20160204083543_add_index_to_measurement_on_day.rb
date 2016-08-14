class AddIndexToMeasurementOnDay < ActiveRecord::Migration
  def self.up
    add_index :measurements, :day
  end

  def self.down
    remove_index :measurements, :day
  end
end
