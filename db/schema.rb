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

ActiveRecord::Schema.define(version: 20150924030315) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.string   "full_name",   limit: 255
    t.string   "first_name",  limit: 255
    t.string   "last_name",   limit: 255
    t.string   "phone",       limit: 255
    t.string   "email",       limit: 255
    t.string   "office_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deals", force: :cascade do |t|
    t.string   "listing_id", limit: 255
    t.decimal  "price",                  precision: 15, scale: 2
    t.decimal  "zestimate",              precision: 15, scale: 2
    t.string   "address",    limit: 255
    t.string   "city",       limit: 255
    t.string   "zipcode",    limit: 255
    t.string   "status",     limit: 255
    t.integer  "agent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deals", ["agent_id"], name: "index_deals_on_agent_id", using: :btree

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
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
