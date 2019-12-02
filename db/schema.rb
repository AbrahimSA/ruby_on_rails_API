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

ActiveRecord::Schema.define(version: 20190917003046) do

  create_table "actors", id: false, force: :cascade do |t|
    t.bigint "id",         null: false
    t.string "login"
    t.string "avatar_url"
    t.index ["id"], name: "index_actors_on_id", unique: true
  end

  create_table "events", id: false, force: :cascade do |t|
    t.bigint   "id",         null: false
    t.text     "type"
    t.datetime "created_at"
    t.bigint   "actor_id"
    t.bigint   "repo_id"
    t.index ["id"], name: "index_events_on_id", unique: true
  end

  create_table "repos", id: false, force: :cascade do |t|
    t.bigint "id",   null: false
    t.text   "name"
    t.text   "url"
    t.index ["id"], name: "index_repos_on_id", unique: true
  end

end
