# BizRecord

`biz_record` is a persistence companion for [`biz`](https://rubygems.org/gems/biz).
It stores schedule configuration in Active Record and rebuilds `Biz::Schedule`
objects for business-time calculations.

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

## Configuration

By default, schedules use Monday to Friday, `09:00` to `17:00`. To change the
weekly hours applied when schedules are created without explicit hours, create
an optional initializer at `config/initializers/biz_record.rb`:

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

Weekdays use the same three-letter keys as `biz`: `sun`, `mon`, `tue`, `wed`,
`thu`, `fri`, and `sat`. Times are normalized to `HH:MM`, sorted by start time,
and overlapping ranges are rejected.

## Models

The main model is `BizRecord::Schedule`.

Declare schedules on the model that owns them:

```ruby
class Account < ApplicationRecord
  has_biz_schedule
  has_biz_schedule :support
  has_biz_schedule :dev
end
```

The DSL defines regular `has_one` associations. It is available automatically
on Active Record models after requiring the gem:

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

`schedulable` is polymorphic and required. Each schedule belongs to one
application record:

```ruby
account.create_support_schedule!
```

`key` is the functional identifier within that schedulable. There is no separate
`name` column.

Schedules expose regular Active Record associations for the editable parts of a
business schedule:

```ruby
schedule.intervals
schedule.shift_days
schedule.break_days
schedule.holiday_days
```

The `configuration` JSON column is a cache for `biz`. When an interval or day is
saved or destroyed, it touches the schedule; the schedule then rebuilds the JSON
from those associations.

```ruby
schedule.to_biz_schedule.in_hours?(Time.current)
```

## Editing Weekly Hours

Weekly hours are intervals owned directly by the schedule. Weekdays use the same
three-letter keys as `biz`: `sun`, `mon`, `tue`, `wed`, `thu`, `fri`, and `sat`.

```ruby
schedule.intervals.create!(
  weekday: "mon",
  starts_at: "09:00",
  ends_at: "17:00"
)
```

## Editing Shifts

Shifts are date-specific business hours. In `biz`, they override the recurring
weekly hours for that date.

```ruby
shift = schedule.shift_days.create!(date: "2026-06-01")

shift.intervals.create!(
  starts_at: "10:00",
  ends_at: "14:00"
)
```

## Editing Breaks

Breaks are date-specific inactive periods within business hours.

```ruby
break_day = schedule.break_days.create!(date: "2026-06-01")

break_day.intervals.create!(
  starts_at: "12:00",
  ends_at: "13:00"
)
```

## Editing Holidays

Holidays are date-specific days without working hours.

```ruby
schedule.holiday_days.create!(date: "2026-12-25")
schedule.holiday_days.create!(date: Date.new(2026, 1, 1))
```

## Validations

Intervals validate owner, start time, end time, weekday ownership, ordering, and
overlaps. Days validate schedule, type, date presence, and uniqueness per
schedule/type.

```ruby
interval = schedule.intervals.build(
  weekday: "mon",
  starts_at: "09:00",
  ends_at: "17:00"
)

interval.valid?
```

The stored configuration uses string keys, ISO 8601 dates, sorted time ranges,
and `HH:MM` times.

## Database Support

The install generator creates a migration that uses `jsonb` on PostgreSQL and
`json` on other Active Record adapters. The model does not depend on querying
inside the JSON column, which keeps the first persistence contract portable
across databases.
