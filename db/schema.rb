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

ActiveRecord::Schema.define(version: 20170203003933) do

  create_table "item_prices", force: :cascade do |t|
    t.integer  "item_id"
    t.float    "price"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "category"
    t.string   "color"
    t.float    "weight"
    t.integer  "inventory_level"
    t.integer  "reorder_level"
    t.boolean  "active",          default: true
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "purchases", force: :cascade do |t|
    t.integer  "item_id"
    t.integer  "quantity"
    t.date     "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
