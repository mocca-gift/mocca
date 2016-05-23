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

ActiveRecord::Schema.define(version: 20160523145451) do

  create_table "anstoevals", force: :cascade do |t|
    t.integer  "answer_id"
    t.integer  "evaluation_id"
    t.integer  "count"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "anstoevals", ["answer_id"], name: "index_anstoevals_on_answer_id"
  add_index "anstoevals", ["evaluation_id"], name: "index_anstoevals_on_evaluation_id"

  create_table "answers", force: :cascade do |t|
    t.integer  "question_id"
    t.integer  "ansid"
    t.integer  "count"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id"

  create_table "calendars", force: :cascade do |t|
    t.integer  "month"
    t.integer  "day"
    t.string   "name1"
    t.string   "name2"
    t.string   "name3"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "evaluations", force: :cascade do |t|
    t.integer  "gift_id"
    t.integer  "evalid"
    t.integer  "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "evaluations", ["gift_id"], name: "index_evaluations_on_gift_id"

  create_table "gifts", force: :cascade do |t|
    t.string   "name"
    t.string   "url"
    t.binary   "img"
    t.string   "img_content_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "lines", force: :cascade do |t|
    t.string   "user"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "topics", force: :cascade do |t|
    t.string   "title"
    t.string   "link"
    t.date     "pubDate"
    t.string   "img"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
