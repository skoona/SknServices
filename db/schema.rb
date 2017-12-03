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

ActiveRecord::Schema.define(version: 20160113200706) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "content_profile_entries", force: :cascade do |t|
    t.string   "topic_value"
    t.string   "topic_type",               limit: 255
    t.string   "topic_type_description",   limit: 255
    t.string   "content_value"
    t.string   "content_type",             limit: 255
    t.string   "content_type_description", limit: 255
    t.string   "description",              limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "content_profiles", force: :cascade do |t|
    t.string   "person_authentication_key", limit: 255
    t.integer  "profile_type_id"
    t.string   "authentication_provider",   limit: 255
    t.string   "username",                  limit: 255
    t.string   "display_name",              limit: 255
    t.string   "email",                     limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.index ["person_authentication_key"], name: "index_content_profiles_on_person_authentication_key", unique: true, using: :btree
    t.index ["profile_type_id"], name: "index_content_profiles_on_profile_type_id", using: :btree
  end

  create_table "content_profiles_entries", force: :cascade do |t|
    t.integer "content_profile_id"
    t.integer "content_profile_entry_id"
    t.index ["content_profile_entry_id"], name: "index_content_profiles_entries_on_content_profile_entry_id", using: :btree
    t.index ["content_profile_id"], name: "index_content_profiles_entries_on_content_profile_id", using: :btree
  end

  create_table "content_type_opts", force: :cascade do |t|
    t.string   "value",           limit: 255
    t.string   "description",     limit: 255
    t.string   "type_name",       limit: 255
    t.integer  "content_type_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["content_type_id"], name: "index_content_types_on_content_type_id", using: :btree
  end

  create_table "content_types", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "description",     limit: 255
    t.string   "value_data_type", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "profile_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "topic_type_opts", force: :cascade do |t|
    t.string   "value",         limit: 255
    t.string   "description",   limit: 255
    t.string   "type_name",     limit: 255
    t.integer  "topic_type_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["topic_type_id"], name: "index_topic_types_on_topic_type_id", using: :btree
  end

  create_table "topic_types", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "description",     limit: 255
    t.string   "value_based_y_n", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "user_group_roles", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.string   "group_type",  limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["name"], name: "index_user_group_roles_on_name", unique: true, using: :btree
  end

  create_table "user_group_roles_user_roles", force: :cascade do |t|
    t.integer "user_group_role_id"
    t.integer "user_role_id"
    t.index ["user_group_role_id"], name: "index_user_group_roles_user_roles_on_user_group_role_id", using: :btree
    t.index ["user_role_id"], name: "index_user_group_roles_user_roles_on_user_role_id", using: :btree
  end

  create_table "user_roles", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["name"], name: "index_user_roles_on_name", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",                 limit: 255
    t.string   "name",                     limit: 255
    t.string   "email",                    limit: 255
    t.string   "password_digest",          limit: 255
    t.string   "remember_token",           limit: 255
    t.string   "password_reset_token",     limit: 255
    t.datetime "password_reset_date"
    t.string   "assigned_groups",          limit: 4096
    t.string   "roles",                    limit: 4096
    t.boolean  "active",                                default: true
    t.string   "file_access_token",        limit: 255
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.string   "person_authenticated_key", limit: 255
    t.string   "assigned_roles",           limit: 4096
    t.string   "remember_token_digest",    limit: 255
    t.string   "user_options",             limit: 4096
    t.index ["person_authenticated_key"], name: "index_users_on_person_authenticated_key", unique: true, using: :btree
    t.index ["remember_token"], name: "index_users_on_remember_token", using: :btree
    t.index ["username"], name: "index_users_on_username", using: :btree
  end

  add_foreign_key "content_profiles", "profile_types"
  add_foreign_key "content_profiles_entries", "content_profile_entries"
  add_foreign_key "content_profiles_entries", "content_profiles"
  add_foreign_key "content_type_opts", "content_types"
  add_foreign_key "topic_type_opts", "topic_types"
  add_foreign_key "user_group_roles_user_roles", "user_group_roles"
  add_foreign_key "user_group_roles_user_roles", "user_roles"
end
