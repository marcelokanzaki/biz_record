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

## Migration

In a Rails application:

```sh
bin/rails generate biz_record:install
bin/rails db:migrate
```

The generated migration uses `jsonb` on PostgreSQL and `json` on other
Active Record adapters. The model does not depend on querying inside the JSON
column, which keeps the first persistence contract portable across databases.
