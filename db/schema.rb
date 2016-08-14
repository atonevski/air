# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160204083543) do

  create_table "measurements", force: :cascade do |t|
    t.date    "day"
    t.integer "parameter_id"
    t.integer "station_id"
    t.integer "count"
    t.float   "min"
    t.float   "max"
    t.float   "avg"
    t.text    "data"
  end

  add_index "measurements", ["day"], name: "index_measurements_on_day"
  add_index "measurements", ["parameter_id"], name: "index_measurements_on_parameter_id"
  add_index "measurements", ["station_id"], name: "index_measurements_on_station_id"

  create_table "parameters", force: :cascade do |t|
    t.string "name"
    t.text   "mk"
    t.string "unit"
    t.string "short"
    t.string "short_no_subscript"
    t.text   "levels"
  end

  add_index "parameters", ["name"], name: "index_parameters_on_name"

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.text   "mk"
  end

  add_index "regions", ["name"], name: "index_regions_on_name"

  create_table "stations", force: :cascade do |t|
    t.string  "name"
    t.text    "mk"
    t.integer "region_id"
  end

  add_index "stations", ["name"], name: "index_stations_on_name"
  add_index "stations", ["region_id"], name: "index_stations_on_region_id"

  create_table "updates", force: :cascade do |t|
    t.date    "day"
    t.integer "parameter_id"
    t.integer "station_id"
  end

  add_index "updates", ["parameter_id"], name: "index_updates_on_parameter_id"
  add_index "updates", ["station_id"], name: "index_updates_on_station_id"

end
