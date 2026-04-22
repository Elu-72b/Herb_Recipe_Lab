# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_04_22_144737) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "caution_tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "drinking_logs", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.integer "rating"
    t.integer "sweetness"
    t.integer "bitterness"
    t.integer "astringency"
    t.integer "freshness"
    t.integer "spicy"
    t.integer "fruity"
    t.integer "acidity"
    t.text "impression"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "flowery", default: 0
    t.index ["recipe_id"], name: "index_drinking_logs_on_recipe_id"
  end

  create_table "flavor_tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flavor_tags_recipes", id: false, force: :cascade do |t|
    t.bigint "flavor_tag_id", null: false
    t.bigint "recipe_id", null: false
  end

  create_table "functional_tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "functional_tags_recipes", id: false, force: :cascade do |t|
    t.bigint "functional_tag_id", null: false
    t.bigint "recipe_id", null: false
  end

  create_table "herb_caution_tags", force: :cascade do |t|
    t.bigint "herb_id", null: false
    t.bigint "caution_tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["caution_tag_id"], name: "index_herb_caution_tags_on_caution_tag_id"
    t.index ["herb_id"], name: "index_herb_caution_tags_on_herb_id"
  end

  create_table "herb_flavor_tags", force: :cascade do |t|
    t.bigint "herb_id", null: false
    t.bigint "flavor_tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flavor_tag_id"], name: "index_herb_flavor_tags_on_flavor_tag_id"
    t.index ["herb_id"], name: "index_herb_flavor_tags_on_herb_id"
  end

  create_table "herb_functional_tags", force: :cascade do |t|
    t.bigint "herb_id", null: false
    t.bigint "functional_tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["functional_tag_id"], name: "index_herb_functional_tags_on_functional_tag_id"
    t.index ["herb_id"], name: "index_herb_functional_tags_on_herb_id"
  end

  create_table "herbs", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "image"
    t.text "caution"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "alias_name"
    t.text "active_ingredients"
    t.text "flavor_description"
    t.text "effect_description"
    t.text "caution_description"
    t.text "history"
  end

  create_table "recipe_herbs", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "herb_id", null: false
    t.float "quantity"
    t.integer "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["herb_id"], name: "index_recipe_herbs_on_herb_id"
    t.index ["recipe_id"], name: "index_recipe_herbs_on_recipe_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "brewed_at"
    t.integer "amount"
    t.text "memo"
    t.boolean "is_public", default: false, null: false
    t.index ["user_id"], name: "index_recipes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "drinking_logs", "recipes"
  add_foreign_key "herb_caution_tags", "caution_tags"
  add_foreign_key "herb_caution_tags", "herbs"
  add_foreign_key "herb_flavor_tags", "flavor_tags"
  add_foreign_key "herb_flavor_tags", "herbs"
  add_foreign_key "herb_functional_tags", "functional_tags"
  add_foreign_key "herb_functional_tags", "herbs"
  add_foreign_key "recipe_herbs", "herbs"
  add_foreign_key "recipe_herbs", "recipes"
  add_foreign_key "recipes", "users"
end
