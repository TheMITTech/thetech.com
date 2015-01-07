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

ActiveRecord::Schema.define(version: 20150107205844) do

  create_table "articles", force: true do |t|
    t.text     "title"
    t.text     "byline"
    t.text     "dateline"
    t.text     "chunks"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "articles_pieces", id: false, force: true do |t|
    t.integer "article_id"
    t.integer "piece_id"
  end

  add_index "articles_pieces", ["article_id", "piece_id"], name: "articles_pieces_index", unique: true

  create_table "articles_users", id: false, force: true do |t|
    t.integer "article_id"
    t.integer "user_id"
  end

  add_index "articles_users", ["article_id", "user_id"], name: "articles_users_index", unique: true

  create_table "images", force: true do |t|
    t.text     "caption"
    t.text     "attribution"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images_pieces", id: false, force: true do |t|
    t.integer "image_id"
    t.integer "piece_id"
  end

  add_index "images_pieces", ["image_id", "piece_id"], name: "images_pieces_index", unique: true

  create_table "images_users", id: false, force: true do |t|
    t.integer "image_id"
    t.integer "user_id"
  end

  add_index "images_users", ["image_id", "user_id"], name: "images_users_index", unique: true

  create_table "pieces", force: true do |t|
    t.text     "web_template"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pieces_series", id: false, force: true do |t|
    t.integer "piece_id"
    t.integer "series_id"
  end

  add_index "pieces_series", ["piece_id", "series_id"], name: "pieces_series_index", unique: true

  create_table "series", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "value"
    t.datetime "created_at"
  end

  add_index "user_roles", ["user_id"], name: "index_user_roles_on_user_id"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
