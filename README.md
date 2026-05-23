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

Declare schedules on the model that owns them:

```ruby
class Account < ApplicationRecord
  has_biz_schedule
  has_biz_schedule :support
  has_biz_schedule :dev
end
```

The DSL defines regular `has_one` associations:

```ruby
account.biz_schedule
account.support_schedule
account.dev_schedule
```

Use the Rails association API to build or create schedules:

```ruby
account.create_biz_schedule!
account.create_support_schedule!
account.build_dev_schedule
```

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

`schedulable` is polymorphic and required. Each schedule belongs to one
application record:

```ruby
account.create_support_schedule!
```

`key` is the functional identifier within that schedulable. There is no separate
`name` column.

## Replacing Configuration

Use `replace_configuration` when an application receives the full schedule state
from a form, API, or seed file. Missing sections are reset to their defaults:
weekly hours use the default business week, while shifts, breaks, and holidays
are cleared.

```ruby
schedule.replace_configuration(
  hours: {
    mon: [
      ["09:00", "12:00"],
      ["13:00", "17:00"]
    ]
  },
  shifts: {
    "2026-06-01" => {
      "10:00" => "14:00"
    }
  },
  breaks: {
    "2026-06-01" => [
      ["12:00", "13:00"]
    ]
  },
  holidays: ["2026-12-25"]
)

schedule.to_biz_configuration
```

The stored configuration is normalized to string keys, ISO 8601 dates, sorted
time ranges, and `HH:MM` times.

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

## Editing Shifts

Shifts are date-specific business hours. In `biz`, they override the recurring
weekly hours for that date.

```ruby
schedule.shifts_for("2026-06-01")
# => [["10:00", "14:00"], ["15:00", "18:00"]]

schedule.add_shift("2026-06-01", "10:00", "14:00")

schedule.replace_shifts("2026-06-01", [
  ["09:00", "12:00"],
  ["13:00", "17:00"]
])

schedule.remove_shift("2026-06-01", "09:00", "12:00")
schedule.clear_shifts("2026-06-01")
schedule.clear_all_shifts
schedule.save!
```

Dates are persisted as ISO 8601 strings. Times are normalized to `HH:MM`,
sorted by start time, and overlapping ranges are rejected.

## Editing Breaks

Breaks are date-specific inactive periods within business hours.

```ruby
schedule.breaks_for("2026-06-01")
# => [["12:00", "13:00"], ["15:00", "15:30"]]

schedule.add_break("2026-06-01", "12:00", "13:00")

schedule.replace_breaks("2026-06-01", [
  ["12:00", "13:00"],
  ["15:00", "15:30"]
])

schedule.remove_break("2026-06-01", "12:00", "13:00")
schedule.clear_breaks("2026-06-01")
schedule.clear_all_breaks
schedule.save!
```

Dates are persisted as ISO 8601 strings. Times are normalized to `HH:MM`,
sorted by start time, and overlapping ranges are rejected.

## Migration

In a Rails application:

```sh
bin/rails generate biz_record:install
bin/rails db:migrate
```

The generated migration uses `jsonb` on PostgreSQL and `json` on other
Active Record adapters. The model does not depend on querying inside the JSON
column, which keeps the first persistence contract portable across databases.
