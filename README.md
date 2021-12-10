# Chopshop::Logreader

This is a simple CLI tool that allows you to find & follow the logs for the most recently running kubernetes pod with a given name for a given status (default status is "Running"). As of now there is no support for searching for pods that started running in a given window of time, although that is a possible feature add if requested. if a valid pod is not found, it will ping the API once a second until one is found or the program is exited. This primarily just wraps some `kubectl` commands and handles parsing the output in standard way to quickly find a pod's logs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chopshop-logreader'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install chopshop-logreader
```

## Getting started

This gem assumes 2 things.

1. you will provide a cloud provider profile (think aws) via one of 3 sources:
    - an option on the command line (`-p PROFILE` or `--profile PROFILE`)
    - via the ENV VAR `AWS_PROFILE`
    - via the ENV VAR `PROFILE`

2. you will provide a tenant via one of 2 sources:
    - an option on the command line (`t TENANT` or `--tenant TENANT`)
    - via the ENV VAR `DEFAULT_TENANT`

Ideally you will set those env vars before starting.

## Usage

to get help:

```bash
chopshop-logreader -h
```

example uses:

```bash
chopshop-logreader SERVICE_NAME_HERE -n connect -s Completed -l 10 -f false
```

```bash
chopshop-logreader SERVICE_NAME_HERE -n connect -s Error -l -1 -f true
```

```bash
chopshop-logreader SERVICE_NAME_HERE -n connect -s Error -l -1 -f true -t some-cool-tenant-name -p my-cool-aws-dev-profile
```

### Default Use

```bash
chopshop-logreader profile-reader
```

expands to

```bash
chopshop-logreader profile-reader -n connect -s Running -l -1 -f true
```

the default use also assumes your have set the ENV VARS `DEFAULT_TENANT` and either `AWS_PROFILE` or `PROFILE`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[tperdue321]/chopshop-logreader. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Chopshop::Logreader project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/chopshop-logreader/blob/master/CODE_OF_CONDUCT.md).

## Project TODO

- add a startup script that will set the default profile/tenant for a user
