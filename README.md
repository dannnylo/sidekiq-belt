# Sidekiq::Belt


<a href='http://badge.fury.io/rb/sidekiq-belt'>
    <img src="https://badge.fury.io/rb/sidekiq-belt.png" alt="Gem Version" />
</a>
<a href='https://github.com/dannnylo/sidekiq-belt/workflows/CI/badge.svg'>
  <img src="https://github.com/dannnylo/sidekiq-belt/workflows/CI/badge.svg" alt="Build Status" />
</a>

This Ruby gem enhances the capabilities of Sidekiq, Sidekiq Pro, and Sidekiq Enterprise by adding essential utilities.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add sidekiq-belt

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install sidekiq-belt

## Features

To enable all features, add the following code to the end of the Sidekiq initializer file:

```ruby
Sidekiq::Belt.use!
```

or

```ruby
Sidekiq::Belt.use!([:all])
```

To enable only specific features, add the following code to the Sidekiq initializer file while passing the necessary options:

```ruby
Sidekiq::Belt.use!([:periodic_run, :periodic_pause])
```

### Run Periodic Jobs Manually (sidekiq-enterprise)

This functionality adds a button on the Sidekiq Enterprise web page that allows manual execution of a job.
To enable this feature, pass the `periodic_run` option:

```ruby
Sidekiq::Belt.use!([:periodic_run])
```

![periodic_run_index](https://github.com/dannnylo/sidekiq-belt/assets/20794/0cc900bc-6925-4139-affd-f41b81318727)
![periodic_run_show](https://github.com/dannnylo/sidekiq-belt/assets/20794/086be190-af8e-44d9-bbf6-eed94b7314a0)


### Pause Periodic Jobs (sidekiq-enterprise)

This option adds a button to pause and unpause the cron of a periodic job.
When a periodic job is paused, the perform is skiped and on server this content is logged.

```
2023-10-12T19:24:00.001Z pid=127183 tid=2ian INFO: Job SomeHourlyWorkerClass is paused by Periodic Pause
```

To enable this feature, pass the `periodic_pause` option:

```ruby
Sidekiq::Belt.use!([:periodic_pause])
```
![periodic_pause](https://github.com/dannnylo/sidekiq-belt/assets/20794/41fbcee4-9c5b-45cd-b6f7-c359a22f3979)
![periodic_unpause](https://github.com/dannnylo/sidekiq-belt/assets/20794/ea06ae37-068e-4f66-ab10-d83970545a59)

### Delete an Unfinished Batch (sidekiq-pro)

This option adds a button to remove failed batches.

To enable this feature, pass the `failed_batch_remove` option:
```ruby
Sidekiq::Belt.use!([:failed_batch_remove])
```
![failed_batch_remove](https://github.com/dannnylo/sidekiq-belt/assets/20794/e285a8b2-4626-48e1-b04a-5190ae51d43b)

### Create a list of jobs to run (sidekiq)
This feature is a manual job manager where you can list jobs. These jobs are grouped and organized in a `Run Jobs` tab.
You can easily and quickly select which job you want to run manually.

To enable this feature, pass the `run_job` option:
```ruby
Sidekiq::Belt.use!([:run_job])
```

![List jobs to run](https://github.com/dannnylo/sidekiq-belt/assets/20794/ed32dac7-46e2-4c44-b3de-69983c3b990c)

To configure the list of jobs

```ruby
Sidekiq::Belt.configure do |config|
  config.run_jobs = [
    { class: "ManualClearDataWorker", args: ['a'] },
    { class: "ManualDoSomethingWorker", args: ['b'] },
    { class: "FirstOperationalWorker", args: ['c'], group: 'Operational' },
    { class: "SecondOperationalWorker", args: ['d'], group: 'Operational' },
    { class: "AnotherGroupWorker", args: ['e'], group: 'Group with a long name' }
  ]
end
```
Or

```ruby
Sidekiq::Belt.configure do |config|
  config.run_jobs.push({ class: "AWorker", args: ["a"] })
  config.run_jobs.push({ class: "BWorker" })

  config.run_jobs << { class: "CWorker", args: ["a"], group: "Etc" }
  config.run_jobs << { class: "DWorker", args: ["a"], group: "Etc" }
end
```

### Add to your web sidekiq a top label by environment (sidekiq)

This feature adds a little line on top of Sidekiq web that shows a configurable message.

![Top Page Development](https://github.com/dannnylo/sidekiq-belt/assets/20794/b1e2f6c2-a257-4172-92ec-09c61511334b)
![Top Page Production](https://github.com/dannnylo/sidekiq-belt/assets/20794/8e64d0e8-dcb2-42ee-b184-67d2f0b2cf6f)

To enable this feature, pass the `top_label` option:
```ruby
Sidekiq::Belt.use!([:top_label])
```

```ruby
Sidekiq::Belt.configure do |config|
  config.top_label = {
    production: {
      background_color: 'red',
      text: 'Be careful',
      color: 'white'
    },
    development: {
      background_color: 'green',
      text: 'You are safe!',
      color: 'white'
    }
  }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dannnylo/sidekiq-belt. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/dannnylo/sidekiq-belt/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sidekiq::Belt project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dannnylo/sidekiq-belt/blob/main/CODE_OF_CONDUCT.md).
