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

ActiveRecord::Schema[7.2].define(version: 2026_07_19_054710) do
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

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "recipe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_bookmarks_on_recipe_id"
    t.index ["user_id", "recipe_id"], name: "index_bookmarks_on_user_id_and_recipe_id", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
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
    t.index ["flavor_tag_id"], name: "index_flavor_tags_recipes_on_flavor_tag_id"
    t.index ["recipe_id"], name: "index_flavor_tags_recipes_on_recipe_id"
  end

  create_table "functional_tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "functional_tags_recipes", id: false, force: :cascade do |t|
    t.bigint "functional_tag_id", null: false
    t.bigint "recipe_id", null: false
    t.index ["functional_tag_id"], name: "index_functional_tags_recipes_on_functional_tag_id"
    t.index ["recipe_id"], name: "index_functional_tags_recipes_on_recipe_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.integer "lock_type", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["created_at"], name: "index_good_jobs_on_created_at"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at_only", where: "(finished_at IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_on_discarded", order: :desc, where: "((finished_at IS NOT NULL) AND (error IS NOT NULL))"
    t.index ["id"], name: "index_good_jobs_on_unfinished_or_errored", where: "((finished_at IS NULL) OR (error IS NOT NULL))"
    t.index ["job_class"], name: "index_good_jobs_on_job_class"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at", "id"], name: "index_good_jobs_for_candidate_dequeue_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["priority", "scheduled_at", "id"], name: "index_good_jobs_on_priority_scheduled_at_unfinished", where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at", "id"], name: "index_good_jobs_on_queue_name_priority_scheduled_at_unfinished", where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["queue_name"], name: "index_good_jobs_on_queue_name"
    t.index ["scheduled_at", "queue_name"], name: "index_good_jobs_on_scheduled_at_and_queue_name"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
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
    t.bigint "user_id"
    t.index ["user_id"], name: "index_herbs_on_user_id"
  end

  create_table "recipe_herbs", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "herb_id"
    t.float "quantity"
    t.integer "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "custom_herb_name"
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
    t.index ["is_public", "created_at"], name: "index_recipes_on_is_public_and_created_at"
    t.index ["user_id"], name: "index_recipes_on_user_id"
  end

  create_table "tea_review_herbs", force: :cascade do |t|
    t.bigint "tea_review_id", null: false
    t.bigint "herb_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "quantity"
    t.string "unit"
    t.string "custom_herb_name"
    t.index ["herb_id"], name: "index_tea_review_herbs_on_herb_id"
    t.index ["tea_review_id"], name: "index_tea_review_herbs_on_tea_review_id"
  end

  create_table "tea_reviews", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "brand"
    t.string "name"
    t.string "purchase_place"
    t.text "description"
    t.integer "rating"
    t.integer "sweetness"
    t.integer "acidity"
    t.integer "bitterness"
    t.integer "astringency"
    t.integer "fruity"
    t.integer "spicy"
    t.integer "freshness"
    t.integer "flowery"
    t.text "impression"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "custom_herb_names", default: [], array: true
    t.index ["user_id"], name: "index_tea_reviews_on_user_id"
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
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookmarks", "recipes"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "drinking_logs", "recipes"
  add_foreign_key "herb_caution_tags", "caution_tags"
  add_foreign_key "herb_caution_tags", "herbs"
  add_foreign_key "herb_flavor_tags", "flavor_tags"
  add_foreign_key "herb_flavor_tags", "herbs"
  add_foreign_key "herb_functional_tags", "functional_tags"
  add_foreign_key "herb_functional_tags", "herbs"
  add_foreign_key "herbs", "users"
  add_foreign_key "recipe_herbs", "herbs"
  add_foreign_key "recipe_herbs", "recipes"
  add_foreign_key "recipes", "users"
  add_foreign_key "tea_review_herbs", "herbs"
  add_foreign_key "tea_review_herbs", "tea_reviews"
  add_foreign_key "tea_reviews", "users"
end
