# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "active_record"
require "biz_record"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :accounts, force: true do |t|
    t.string :name
    t.timestamps
  end

  create_table :biz_record_schedules, force: true do |t|
    t.references :schedulable, polymorphic: true, index: false
    t.string :key, null: false, default: "default"
    t.string :time_zone, null: false, default: "Etc/UTC"
    t.json :configuration, null: false
    t.timestamps
  end
end

class Account < ActiveRecord::Base
  has_many :biz_record_schedules, as: :schedulable, class_name: "BizRecord::Schedule"
end
