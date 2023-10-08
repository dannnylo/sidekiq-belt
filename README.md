# Sidekiq::Belt

This Ruby gem enhances the capabilities of Sidekiq, Sidekiq Pro, and Sidekiq Enterprise by adding essential utilities.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add sidekiq-belt

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install sidekiq-belt

## Features

GitHub Copilot: Sure, here's a rewritten version of the content that is easier to read for a developer:

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

![periodic_run_index](https://github.com/dannnylo/sidekiq-belt/assets/20794/1c6ceed7-c2be-447e-b61c-b1e15f002bc2)
![periodic_run_show](https://github.com/dannnylo/sidekiq-belt/assets/20794/be8cab4b-bfb1-4e15-b01b-56c69231169b)

### Pause Periodic Jobs (sidekiq-enterprise)

This feature is not yet implemented.

### Delete an Unfinished Batch (sidekiq-pro)

This feature is not yet implemented.
```
Sidekiq::Belt.use!
```

or

```
Sidekiq::Belt.use!([:all])
```

To enable only the features you want, add the code to the Sidekiq initializer file while passing the necessary options.

```
Sidekiq::Belt.use!([:periodic_run, :periodic_pause])
```

### Run manualy Periodic Jobs (sidekiq-enterprise)

This functionality adds a button on the Sidekiq Enterprise web page that allows manual execution of a job.

To enable this feature, pass the periodic_run option:

```
Sidekiq::Belt.use!([:periodic_run])
```

![periodic_run_index](https://github.com/dannnylo/sidekiq-belt/assets/20794/1c6ceed7-c2be-447e-b61c-b1e15f002bc2)
![periodic_run_show](https://github.com/dannnylo/sidekiq-belt/assets/20794/be8cab4b-bfb1-4e15-b01b-56c69231169b)

### Pause Periodic Jobs (sidekiq-enterprise)

It will be implemented in upcoming versions.

### Delete a not finished Batch (sidekiq-pro)

It will be implemented in upcoming versions.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dannnylo/sidekiq-belt. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/dannnylo/sidekiq-belt/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sidekiq::Belt project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dannnylo/sidekiq-belt/blob/main/CODE_OF_CONDUCT.md).
