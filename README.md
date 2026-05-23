# BizRecord

`biz_record` is a persistence companion for [`biz`](https://rubygems.org/gems/biz).
It stores schedule configuration in Active Record and rebuilds `Biz::Schedule`
objects for business-time calculations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "biz_record"
```

## Model

The main model is `BizRecord::Schedule`.

```ruby
schedule = BizRecord::Schedule.create!(
  schedulable: account,
  key: "support",
  time_zone: "America/Sao_Paulo",
  configuration: {
    hours: {
      mon: { "09:00" => "17:00" },
      tue: { "09:00" => "17:00" },
      wed: { "09:00" => "17:00" },
      thu: { "09:00" => "17:00" },
      fri: { "09:00" => "17:00" }
    },
    shifts: {},
    breaks: {},
    holidays: []
  }
)

schedule.to_biz_schedule.in_hours?(Time.current)
```

`schedulable` is polymorphic and optional, so applications can keep both owned
schedules and global schedules:

```ruby
BizRecord::Schedule.create!(key: "default")
account.biz_record_schedules.create!(key: "support")
```

`key` is the functional identifier for a schedule. There is no separate `name`
column.

## Editing Weekly Hours

Applications should edit weekly hours through the schedule API instead of
writing directly to the JSON column.

```ruby
schedule = BizRecord::Schedule.find_by!(key: "support")

schedule.hours_for(:mon)
# => [["09:00", "12:00"], ["13:00", "17:00"]]

schedule.add_hours(:mon, "09:00", "12:00")
schedule.add_hours(:mon, "13:00", "17:00")

schedule.replace_hours(:mon, [
  ["08:00", "12:00"],
  ["14:00", "18:00"]
])

schedule.remove_hours(:mon, "08:00", "12:00")
schedule.clear_hours(:mon)
schedule.save!
```

Weekdays use the same three-letter keys as `biz`: `sun`, `mon`, `tue`, `wed`,
`thu`, `fri`, and `sat`. Times are normalized to `HH:MM`, sorted by start time,
and overlapping ranges are rejected.

## Editing Holidays

Holidays are persisted as ISO 8601 dates inside the schedule configuration.

```ruby
schedule.add_holiday("2026-12-25")
schedule.add_holiday(Date.new(2026, 1, 1))

schedule.holiday?("2026-12-25")
# => true

schedule.replace_holidays(["2026-01-01", "2026-12-25"])
schedule.remove_holiday("2026-01-01")
schedule.clear_holidays
schedule.save!
```

Dates are normalized, sorted, and deduplicated before being stored.

## Migration

In a Rails application:

```sh
bin/rails generate biz_record:install
bin/rails db:migrate
```

The generated migration uses `jsonb` on PostgreSQL and `json` on other
Active Record adapters. The model does not depend on querying inside the JSON
column, which keeps the first persistence contract portable across databases.
