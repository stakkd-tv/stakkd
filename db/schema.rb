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

ActiveRecord::Schema[8.0].define(version: 2025_06_30_172019) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.text "colours", default: ["#f7567c"], array: true
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

  create_table "alternative_names", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.bigint "country_id", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_alternative_names_on_country_id"
    t.index ["record_type", "record_id"], name: "index_alternative_names_on_record"
  end

  create_table "cast_members", force: :cascade do |t|
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "person_id", null: false
    t.string "character", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_cast_members_on_person_id"
    t.index ["record_type", "record_id"], name: "index_cast_members_on_record"
  end

  create_table "certifications", force: :cascade do |t|
    t.string "media_type", null: false
    t.bigint "country_id", null: false
    t.string "code", null: false
    t.string "description", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_certifications_on_country_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "description"
    t.string "homepage"
    t.string "name"
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_companies_on_country_id"
  end

  create_table "company_assignments", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "record_type", "record_id"], name: "index_unique_company_assignments", unique: true
    t.index ["company_id"], name: "index_company_assignments_on_company_id"
    t.index ["record_type", "record_id"], name: "index_company_assignments_on_record"
  end

  create_table "countries", force: :cascade do |t|
    t.string "code"
    t.string "translated_name"
    t.string "original_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_countries_on_code", unique: true
  end

  create_table "genre_assignments", force: :cascade do |t|
    t.bigint "genre_id", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id", "record_type", "record_id"], name: "index_unique_genre_assignments", unique: true
    t.index ["genre_id"], name: "index_genre_assignments_on_genre_id"
    t.index ["record_type", "record_id"], name: "index_genre_assignments_on_record"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_genres_on_name", unique: true
  end

  create_table "languages", force: :cascade do |t|
    t.string "code"
    t.string "translated_name"
    t.string "original_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_languages_on_code", unique: true
  end

  create_table "movies", force: :cascade do |t|
    t.bigint "language_id"
    t.bigint "country_id"
    t.string "original_title", null: false
    t.string "translated_title", null: false
    t.text "overview"
    t.string "status", default: "in production", null: false
    t.integer "runtime", default: 0, null: false
    t.decimal "revenue", default: "0.0", null: false
    t.decimal "budget", default: "0.0", null: false
    t.string "homepage"
    t.string "imdb_id"
    t.string "title_kebab", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_movies_on_country_id"
    t.index ["language_id"], name: "index_movies_on_language_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "alias"
    t.text "biography"
    t.date "dob"
    t.date "dod"
    t.string "gender", default: "unknown"
    t.string "imdb_id"
    t.string "known_for"
    t.string "original_name", null: false
    t.string "translated_name", null: false
    t.string "name_kebab", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "releases", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.bigint "certification_id", null: false
    t.string "type", null: false
    t.string "note"
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["certification_id"], name: "index_releases_on_certification_id"
    t.index ["movie_id"], name: "index_releases_on_movie_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "taglines", force: :cascade do |t|
    t.string "tagline", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_taglines_on_record"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "videos", force: :cascade do |t|
    t.string "name"
    t.string "source_key", null: false
    t.string "source", null: false
    t.string "type", null: false
    t.string "thumbnail_url"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_videos_on_record"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alternative_names", "countries"
  add_foreign_key "cast_members", "people"
  add_foreign_key "certifications", "countries"
  add_foreign_key "company_assignments", "companies"
  add_foreign_key "genre_assignments", "genres"
  add_foreign_key "releases", "certifications"
  add_foreign_key "releases", "movies"
  add_foreign_key "sessions", "users"
  add_foreign_key "taggings", "tags"
end
