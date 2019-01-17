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

ActiveRecord::Schema.define(version: 2019_01_02_033531) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "api_clients", force: :cascade do |t|
    t.string "name", null: false
    t.uuid "key", default: -> { "uuid_generate_v4()" }, null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.index ["key"], name: "index_api_clients_on_key", unique: true
    t.index ["name"], name: "index_api_clients_on_name"
  end

  create_table "athlete_activity_analyses", force: :cascade do |t|
    t.datetime "as_of"
    t.string "dow"
    t.bigint "athlete_id"
    t.integer "tweets", default: 0
    t.integer "retweets", default: 0
    t.integer "likes", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_athlete_activity_analyses_on_athlete_id"
  end

  create_table "athlete_report_data", force: :cascade do |t|
    t.datetime "as_of"
    t.bigint "athlete_id"
    t.bigint "user_id"
    t.bigint "organization_id"
    t.integer "retweets", default: 0
    t.integer "likes", default: 0
    t.integer "mentions", default: 0
    t.integer "dms", default: 0
    t.integer "sms", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_athlete_report_data_on_athlete_id"
    t.index ["organization_id"], name: "index_athlete_report_data_on_organization_id"
    t.index ["user_id"], name: "index_athlete_report_data_on_user_id"
  end

  create_table "athlete_sentiment_analyses", force: :cascade do |t|
    t.datetime "as_of"
    t.bigint "athlete_id"
    t.float "mixed", default: 0.0
    t.float "negative", default: 0.0
    t.float "neutral", default: 0.0
    t.float "positive", default: 0.0
    t.string "sentiment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_athlete_sentiment_analyses_on_athlete_id"
  end

  create_table "athlete_uploads", force: :cascade do |t|
    t.bigint "user_id"
    t.string "athlete_list_file_name"
    t.string "athlete_list_content_type"
    t.integer "athlete_list_file_size"
    t.datetime "athlete_list_updated_at"
    t.string "status", default: "pending"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_athlete_uploads_on_user_id"
  end

  create_table "athletes", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "email"
    t.string "nick_name"
    t.string "grad_year"
    t.string "high_school"
    t.string "state"
    t.string "coach_name"
    t.string "mothers_name"
    t.string "fathers_name"
    t.string "hudl_id"
    t.string "arms_id"
    t.string "twitter_profile_id"
    t.string "instagram_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "position"
    t.date "graduation_year"
  end

  create_table "authentications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid"], name: "index_authentications_on_provider_and_uid"
  end

  create_table "board_uploads", force: :cascade do |t|
    t.string "user_id", null: false
    t.string "board_file_name", null: false
    t.string "board_content_type", null: false
    t.integer "board_file_size", null: false
    t.datetime "board_updated_at", null: false
    t.boolean "delete_boards", default: false
    t.boolean "delete_athletes", default: false
    t.integer "requestor", null: false
    t.boolean "processed", default: false
  end

  create_table "calendar", id: false, force: :cascade do |t|
    t.date "date"
    t.float "year"
    t.float "month"
    t.text "monthname"
    t.float "day"
    t.float "dayofyear"
    t.text "weekdayname"
    t.float "calendarweek"
    t.text "formatteddate"
    t.text "quartal"
    t.text "yearquartal"
    t.text "yearmonth"
    t.text "yearcalendarweek"
    t.text "weekend"
    t.text "americanholiday"
    t.text "austrianholiday"
    t.text "canadianholiday"
    t.text "period"
    t.date "cwstart"
    t.date "cwend"
    t.date "monthstart"
    t.datetime "monthend"
  end

  create_table "co_email_groupings", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "co_email_recipients", force: :cascade do |t|
    t.string "email"
    t.string "full_name"
    t.boolean "enabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "co_email_settings", force: :cascade do |t|
    t.string "campaign_id"
    t.string "list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "header_text"
    t.string "commit_keywords"
    t.string "offer_keywords"
  end

  create_table "conferences", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "is_power_five", default: false
    t.integer "sort", default: 999999
    t.string "football_subdivision"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "twitter_profile_id"
    t.bigint "tweet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tweet_id"], name: "index_favorites_on_tweet_id"
    t.index ["twitter_profile_id"], name: "index_favorites_on_twitter_profile_id"
  end

  create_table "filters", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "team_id"
    t.boolean "is_shared", default: false, null: false
    t.string "name", null: false
    t.string "filterable_type", null: false
    t.string "criteria", null: false
    t.boolean "is_archived", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_filters_on_team_id"
    t.index ["user_id"], name: "index_filters_on_user_id"
  end

  create_table "followers", force: :cascade do |t|
    t.bigint "twitter_profile_id"
    t.bigint "follower_id"
    t.datetime "unfollow_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["follower_id"], name: "index_followers_on_follower_id"
    t.index ["twitter_profile_id", "follower_id"], name: "index_followers_on_twitter_profile_id_and_follower_id", unique: true
    t.index ["twitter_profile_id"], name: "index_followers_on_twitter_profile_id"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "media", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "object_file_name"
    t.string "object_content_type"
    t.integer "object_file_size"
    t.datetime "object_updated_at"
    t.string "twitter_media_id"
    t.string "owner"
    t.string "group"
    t.string "twitter_media_status"
    t.string "oauth_token"
    t.string "oauth_secret"
    t.string "twitter_media_status_message"
  end

  create_table "message_recipients", force: :cascade do |t|
    t.bigint "message_id"
    t.string "recipient"
    t.string "grouping"
    t.string "platform"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "sent_at"
    t.string "status", default: "pending"
    t.string "response"
    t.string "platform_response_id"
    t.string "name"
    t.datetime "send_at"
    t.bigint "athlete_id"
    t.bigint "platform_id"
    t.index ["athlete_id"], name: "index_message_recipients_on_athlete_id"
    t.index ["message_id"], name: "index_message_recipients_on_message_id"
    t.index ["platform_id"], name: "index_message_recipients_on_platform_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "body"
    t.string "media_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sender"
    t.string "oauth_token"
    t.string "oauth_secret"
    t.string "status", default: "Pending"
    t.string "team"
    t.string "platform_media_id"
    t.string "platform_media_status"
    t.bigint "team_id"
    t.bigint "user_id"
    t.index ["team_id"], name: "index_messages_on_team_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "organization_aliases", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "alias"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_organization_aliases_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "address"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "stripe_customer_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "nickname"
    t.string "mascot"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.string "primary_color"
    t.string "secondary_color"
  end

  create_table "platforms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "positions", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.string "standardized_name"
    t.string "role"
    t.string "alternate_names"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "sms_events", force: :cascade do |t|
    t.string "event_type"
    t.string "direction"
    t.string "from"
    t.string "to"
    t.string "message_id"
    t.string "message_uri"
    t.string "text"
    t.string "tag"
    t.integer "segment_count"
    t.string "application_id"
    t.datetime "time"
    t.string "state"
    t.string "delivery_state"
    t.string "delivery_code"
    t.string "delivery_description"
    t.string "media", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "team_athlete_id"
    t.index ["team_athlete_id"], name: "index_sms_events_on_team_athlete_id"
    t.index ["user_id"], name: "index_sms_events_on_user_id"
  end

  create_table "sms_numbers", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "state"
    t.string "status"
    t.bigint "number"
    t.string "national_number"
    t.string "bandwidth_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sms_numbers_on_user_id"
  end

  create_table "social_accounts", force: :cascade do |t|
    t.string "sociable_type"
    t.bigint "sociable_id"
    t.bigint "platform_id"
    t.integer "account_id"
    t.string "token"
    t.string "secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_social_accounts_on_account_id"
    t.index ["platform_id"], name: "index_social_accounts_on_platform_id"
    t.index ["sociable_type", "sociable_id"], name: "index_social_accounts_on_sociable_type_and_sociable_id"
  end

  create_table "sports", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.string "group"
    t.index ["name", "group"], name: "index_tags_on_name_and_group", unique: true
  end

  create_table "team_athletes", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "nick_name"
    t.string "phone"
    t.string "email"
    t.string "high_school"
    t.string "state"
    t.string "coach_name"
    t.string "mothers_name"
    t.string "fathers_name"
    t.string "positions"
    t.date "graduation_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "athlete_id"
    t.bigint "team_id"
    t.index ["athlete_id", "team_id"], name: "uniq_athlete_team_idx", unique: true
    t.index ["athlete_id"], name: "index_team_athletes_on_athlete_id"
    t.index ["team_id"], name: "index_team_athletes_on_team_id"
  end

  create_table "team_users", force: :cascade do |t|
    t.bigint "team_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "user_id"], name: "index_team_users_on_team_id_and_user_id", unique: true
    t.index ["team_id"], name: "index_team_users_on_team_id"
    t.index ["user_id"], name: "index_team_users_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "photo_url"
    t.string "phone"
    t.datetime "trial_start_date"
    t.string "override_plan_id"
    t.bigint "organization_id"
    t.string "stripe_subscription_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "conference_id"
    t.string "division"
    t.bigint "sport_id"
    t.index ["conference_id"], name: "index_teams_on_conference_id"
    t.index ["organization_id"], name: "index_teams_on_organization_id"
    t.index ["sport_id"], name: "index_teams_on_sport_id"
  end

  create_table "temp_athletes", force: :cascade do |t|
    t.integer "grad_year"
    t.text "positions"
    t.text "first_name"
    t.text "last_name"
    t.text "address"
    t.text "state"
    t.text "city"
    t.text "zip_code"
    t.text "twitter_handle"
    t.text "mobile"
    t.text "email"
    t.text "hs_name"
    t.text "hs_state"
    t.integer "priority", default: -1
    t.boolean "ignore", default: false
    t.string "twitter_id"
    t.datetime "cache_date", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "temp_commit_offers", force: :cascade do |t|
    t.string "program_name"
    t.string "recruit_name"
    t.string "position"
    t.string "grad_year"
    t.string "high_school"
    t.string "state"
    t.string "twitter_handle"
    t.string "tweet_text"
    t.string "tweet_permalink"
    t.boolean "deleted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "conference"
    t.string "verified_by"
    t.string "keyword"
    t.string "grouping", default: "Other Commitments"
    t.bigint "organization_id"
    t.datetime "sent_on"
    t.index ["organization_id"], name: "index_temp_commit_offers_on_organization_id"
    t.index ["program_name", "recruit_name", "twitter_handle", "tweet_text", "keyword"], name: "uniq_cols_idx", unique: true
  end

  create_table "tweets", id: :bigint, default: nil, force: :cascade do |t|
    t.string "id_str"
    t.datetime "created_at", null: false
    t.string "text"
    t.boolean "truncated"
    t.string "source"
    t.bigint "in_reply_to_status_id"
    t.string "in_reply_to_status_id_str"
    t.bigint "in_reply_to_user_id"
    t.string "in_reply_to_user_id_str"
    t.string "in_reply_to_screen_name"
    t.bigint "twitter_profile_id"
    t.bigint "quoted_status_id"
    t.string "quoted_status_id_str"
    t.boolean "is_quote_status"
    t.integer "retweeted_status"
    t.integer "quote_count"
    t.integer "retweet_count"
    t.integer "favorite_count"
    t.boolean "possibly_sensitive"
    t.string "filter_level"
    t.string "hashtags"
    t.string "urls"
    t.string "user_mentions"
    t.string "media"
    t.string "symbols"
    t.string "polls"
    t.string "lang"
    t.datetime "updated_at", null: false
    t.boolean "is_questionable", default: false
    t.boolean "is_commit", default: false
    t.boolean "is_offer", default: false
    t.index ["id"], name: "index_tweets_on_id", unique: true
    t.index ["text", "created_at"], name: "text_created_at_idx"
    t.index ["twitter_profile_id"], name: "index_tweets_on_twitter_profile_id"
  end

  create_table "twitter_cache_dates", force: :cascade do |t|
    t.bigint "athlete_id"
    t.datetime "profile"
    t.datetime "tweets"
    t.datetime "followers"
    t.datetime "favorites"
    t.datetime "friends"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_twitter_cache_dates_on_athlete_id"
  end

  create_table "twitter_profiles", force: :cascade do |t|
    t.bigint "twitter_id"
    t.string "id_str"
    t.string "name"
    t.string "screen_name"
    t.string "location"
    t.string "profile_location"
    t.string "description"
    t.string "url"
    t.boolean "protected"
    t.integer "followers_count"
    t.integer "friends_count"
    t.integer "listed_count"
    t.datetime "profile_created_at"
    t.integer "favorites_count"
    t.string "utc_offset"
    t.string "time_zone"
    t.boolean "geo_enabled"
    t.boolean "verified"
    t.integer "statuses_count"
    t.string "lang"
    t.boolean "contributors_enabled"
    t.boolean "is_translator"
    t.boolean "is_translation_enabled"
    t.string "profile_background_color"
    t.string "profile_background_image_url"
    t.string "profile_background_image_url_https"
    t.boolean "profile_background_tile"
    t.string "profile_image_url"
    t.string "profile_image_url_https"
    t.string "profile_banner_url"
    t.string "profile_link_color"
    t.string "profile_sidebar_border_color"
    t.string "profile_sidebar_fill_color"
    t.string "profile_text_color"
    t.boolean "profile_use_background_image"
    t.boolean "has_extended_profile"
    t.boolean "default_profile"
    t.boolean "default_profile_image"
    t.boolean "notifications"
    t.string "translator_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "twitter_user_rate_limits", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "myself"
    t.datetime "users"
    t.datetime "tweets"
    t.datetime "followers"
    t.datetime "friends"
    t.datetime "favorites"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_twitter_user_rate_limits_on_user_id"
  end

  create_table "user_social_accounts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "platform_id"
    t.string "platform_account_id"
    t.string "oauth_token"
    t.string "oauth_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_primary", default: false
    t.index ["platform_id"], name: "index_user_social_accounts_on_platform_id"
    t.index ["user_id"], name: "index_user_social_accounts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "activation_state"
    t.string "activation_token"
    t.datetime "activation_token_expires_at"
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.integer "access_count_to_reset_password_page", default: 0
    t.integer "failed_logins_count", default: 0
    t.datetime "lock_expires_at"
    t.string "unlock_token"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string "last_login_from_ip_address"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "magic_login_token"
    t.datetime "magic_login_token_expires_at"
    t.datetime "magic_login_email_sent_at"
    t.string "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string "organization"
    t.bigint "sms_numbers_id"
    t.index ["activation_token"], name: "index_users_on_activation_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["last_logout_at", "last_activity_at"], name: "index_users_on_last_logout_at_and_last_activity_at"
    t.index ["magic_login_token"], name: "index_users_on_magic_login_token"
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
    t.index ["sms_numbers_id"], name: "index_users_on_sms_numbers_id"
    t.index ["unlock_token"], name: "index_users_on_unlock_token"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "athlete_activity_analyses", "athletes"
  add_foreign_key "athlete_report_data", "athletes"
  add_foreign_key "athlete_report_data", "organizations"
  add_foreign_key "athlete_report_data", "users"
  add_foreign_key "athlete_sentiment_analyses", "athletes"
  add_foreign_key "athlete_uploads", "users"
  add_foreign_key "favorites", "tweets"
  add_foreign_key "favorites", "twitter_profiles"
  add_foreign_key "filters", "teams"
  add_foreign_key "filters", "users"
  add_foreign_key "followers", "twitter_profiles"
  add_foreign_key "followers", "twitter_profiles", column: "follower_id"
  add_foreign_key "message_recipients", "messages"
  add_foreign_key "message_recipients", "platforms"
  add_foreign_key "organization_aliases", "organizations"
  add_foreign_key "sms_events", "team_athletes"
  add_foreign_key "sms_events", "users"
  add_foreign_key "sms_numbers", "users"
  add_foreign_key "team_athletes", "athletes"
  add_foreign_key "team_athletes", "teams"
  add_foreign_key "team_users", "teams"
  add_foreign_key "team_users", "users"
  add_foreign_key "teams", "conferences"
  add_foreign_key "teams", "organizations"
  add_foreign_key "teams", "sports"
  add_foreign_key "temp_commit_offers", "organizations"
  add_foreign_key "tweets", "twitter_profiles"
  add_foreign_key "twitter_cache_dates", "athletes"
  add_foreign_key "user_social_accounts", "platforms", name: "user_social_accounts_platform_id_fkey"
  add_foreign_key "user_social_accounts", "users", name: "user_social_accounts_user_id_fkey"
end
