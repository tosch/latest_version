# LatestVersion

Sinatra application that lists the latest releases for a GitHub user's repositories.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'latest_version', git: 'https://github.com/tosch/latest_version.git'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install latest_version

## Usage

Create a `config.ru` like this:

```ruby
require "latest_version"

run LatestVersion::App
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tosch/latest_version.
