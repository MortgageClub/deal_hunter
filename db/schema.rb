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

ActiveRecord::Schema.define(version: 20171028054929) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.text     "full_name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "email"
    t.text     "office_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "contact"
    t.text     "fax"
    t.text     "lic"
    t.text     "web_page"
    t.text     "address"
    t.string   "broker_code"
    t.string   "agent_type"
  end

  create_table "deals", force: :cascade do |t|
    t.string   "listing_id"
    t.decimal  "price",       precision: 15, scale: 2
    t.decimal  "zestimate",   precision: 15, scale: 2
    t.string   "address"
    t.string   "city"
    t.string   "zipcode"
    t.string   "status"
    t.integer  "agent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "home_type"
    t.string   "home_status"
    t.integer  "bedroom"
    t.string   "bathroom"
    t.string   "dom_cdom"
    t.text     "remark"
    t.boolean  "hot_deal",                             default: false
    t.decimal  "comp",        precision: 15, scale: 2
    t.float    "sq_ft"
  end

  add_index "deals", ["agent_id"], name: "index_deals_on_agent_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "listings", force: :cascade do |t|
    t.string   "chg_type"
    t.string   "mls"
    t.string   "address"
    t.string   "city"
    t.text     "sq_ft"
    t.integer  "year_built"
    t.integer  "bed_rooms"
    t.text     "bath_rooms"
    t.decimal  "price",          precision: 15, scale: 3
    t.text     "lot_sz"
    t.integer  "market_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "hot_deal"
    t.decimal  "zestimate",      precision: 15, scale: 3
    t.decimal  "comp",           precision: 15, scale: 3
    t.datetime "added_date"
    t.decimal  "rent",           precision: 15, scale: 3
    t.decimal  "arv",            precision: 15, scale: 3
    t.decimal  "arv_percentage", precision: 15, scale: 4
    t.boolean  "is_sent"
  end

  add_index "listings", ["market_id"], name: "index_listings_on_market_id", using: :btree

  create_table "markets", force: :cascade do |t|
    t.string   "portal_url"
    t.decimal  "rehab_cost",       precision: 15, scale: 3
    t.decimal  "arv_percent",      precision: 15, scale: 3
    t.decimal  "comps_weight",     precision: 15, scale: 3
    t.decimal  "zestimate_weight", precision: 15, scale: 3
    t.string   "from_email"
    t.string   "to_email"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "name"
    t.boolean  "is_first_crawl"
  end

  create_table "messages", force: :cascade do |t|
    t.text     "content"
    t.text     "reply"
    t.integer  "messageable_id"
    t.string   "messageable_type"
    t.string   "phone_number"
    t.string   "status"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "reports", force: :cascade do |t|
    t.string   "result"
    t.text     "raw_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string   "alias"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "role"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "listings", "markets"
end
