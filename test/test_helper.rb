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
    t.references :schedulable, polymorphic: true, null: false, index: false
    t.string :key, null: false, default: "default"
    t.string :time_zone, null: false, default: "Etc/UTC"
    t.json :configuration, null: false
    t.timestamps
  end

  add_index :biz_record_schedules,
            [:schedulable_type, :schedulable_id, :key],
            unique: true,
            name: "index_biz_record_schedules_on_schedulable_and_key"
end

class Account < ActiveRecord::Base
  has_biz_schedule
  has_biz_schedule :support
  has_biz_schedule :dev
end

module BizRecordTestHelpers
  def before_setup
    super
    BizRecord.reset_configuration!
  end

  def account
    @account ||= Account.create!(name: "Acme")
  end

  def build_schedule(attributes = {})
    BizRecord::Schedule.new({ schedulable: account }.merge(attributes))
  end

  def create_schedule!(attributes = {})
    BizRecord::Schedule.create!({ schedulable: account }.merge(attributes))
  end
end

Minitest::Test.include BizRecordTestHelpers
