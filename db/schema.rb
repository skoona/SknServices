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

ActiveRecord::Schema.define(version: 20151222035102) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "content_profile_entries", force: :cascade do |t|
    t.string   "topic_value"
    t.string   "content_value"
    t.integer  "content_type_id"
    t.integer  "topic_type_id"
    t.integer  "content_profile_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "description"
  end

  add_index "content_profile_entries", ["content_profile_id"], name: "index_content_profile_entries_on_content_profile_id", using: :btree
  add_index "content_profile_entries", ["content_type_id"], name: "index_content_profile_entries_on_content_type_id", using: :btree
  add_index "content_profile_entries", ["topic_type_id"], name: "index_content_profile_entries_on_topic_type_id", using: :btree

  create_table "content_profiles", force: :cascade do |t|
    t.string   "person_authentication_key"
    t.integer  "profile_type_id"
    t.string   "authentication_provider"
    t.string   "username"
    t.string   "display_name"
    t.string   "email"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "content_profiles", ["person_authentication_key"], name: "index_content_profiles_on_person_authentication_key", unique: true, using: :btree
  add_index "content_profiles", ["profile_type_id"], name: "index_content_profiles_on_profile_type_id", using: :btree

  create_table "content_type_opts", force: :cascade do |t|
    t.string   "value"
    t.string   "description"
    t.integer  "content_type_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "content_type_opts", ["content_type_id"], name: "index_content_type_opts_on_content_type_id", using: :btree

  create_table "content_types", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "value_data_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "profile_types", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "topic_type_opts", force: :cascade do |t|
    t.string   "value"
    t.string   "description"
    t.integer  "topic_type_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "topic_type_opts", ["topic_type_id"], name: "index_topic_type_opts_on_topic_type_id", using: :btree

  create_table "topic_types", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "value_based_y_n"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "remember_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_date"
    t.string   "role_groups"
    t.string   "roles"
    t.boolean  "active",                   default: true
    t.string   "file_access_token"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "person_authenticated_key"
  end

  add_index "users", ["person_authenticated_key"], name: "index_users_on_person_authenticated_key", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  add_foreign_key "content_profile_entries", "content_profiles"
  add_foreign_key "content_profile_entries", "content_types"
  add_foreign_key "content_profile_entries", "topic_types"
  add_foreign_key "content_profiles", "profile_types"
  add_foreign_key "content_type_opts", "content_types"
  add_foreign_key "topic_type_opts", "topic_types"
end
