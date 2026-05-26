# BizRecord

`biz_record` is a Rails engine that stores [`biz`](https://rubygems.org/gems/biz)
schedules in Active Record.

It persists weekly hours, date-specific shifts, breaks, holidays, and an IANA
time zone, then rebuilds a `Biz::Schedule` for business-time calculations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "biz_record"
```

Then install the migration:

```sh
bin/rails generate biz_record:install
bin/rails db:migrate
```

The engine includes routes and controllers with simple Rails forms for editing
schedules. They are a reference implementation: mount them in your app if you
want a working base to adapt to your own UI and business rules.

```ruby
mount BizRecord::Engine => "/biz_record"
```

## Defaults

Schedules default to `Etc/UTC` and Monday-Friday, `09:00`-`17:00`.
Change the default weekly hours with an initializer:

```ruby
BizRecord.configure do |config|
  config.default_hours = {
    mon: { "08:00" => "12:00", "13:00" => "17:00" },
    tue: { "08:00" => "12:00", "13:00" => "17:00" },
    wed: { "08:00" => "12:00", "13:00" => "17:00" },
    thu: { "08:00" => "12:00", "13:00" => "17:00" },
    fri: { "08:00" => "12:00", "13:00" => "16:00" }
  }
end
```

Weekdays use `biz` keys: `sun`, `mon`, `tue`, `wed`, `thu`, `fri`, `sat`.

## Usage

Declare one or more schedules on the model that owns them:

```ruby
class Account < ApplicationRecord
  has_biz_schedule
  has_biz_schedule :support
  has_biz_schedule :dev
end
```

This defines regular `has_one` associations:

```ruby
account.biz_schedule
account.support_schedule
account.dev_schedule

account.create_biz_schedule!
account.create_support_schedule!(time_zone: "America/Sao_Paulo")
```

`key` identifies the schedule within its owner. The default key is `"default"`;
named schedules use the name passed to `has_biz_schedule`.

Edit the persisted parts through associations:

```ruby
schedule = account.support_schedule

schedule.intervals.create!(weekday: "mon", starts_at: "09:00", ends_at: "17:00")

shift = schedule.shift_days.create!(date: "2026-06-01")
shift.intervals.create!(starts_at: "10:00", ends_at: "14:00")

break_day = schedule.break_days.create!(date: "2026-06-01")
break_day.intervals.create!(starts_at: "12:00", ends_at: "13:00")

schedule.holiday_days.create!(date: "2026-12-25")

schedule.to_biz_schedule.in_hours?(Time.current)
```

## Data Model

- `BizRecord::Schedule` belongs to a polymorphic `schedulable`.
- `BizRecord::Interval` stores weekly hours or day-specific intervals.
- `BizRecord::Days::Shift`, `Break`, and `Holiday` store date exceptions.
- The `configuration` JSON column is a cache rebuilt from associations.
- The generator uses `jsonb` on PostgreSQL and `json` elsewhere.
