# RuboCop::Rails::OrderModelMacros

TODO: Add overview/docs

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubocop-rails-order_model_macros'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install rubocop-rails-order_model_macros
```

## Usage

You need to tell RuboCop to load the `Rails/OrderModelMacros` extension. There are three ways to do this:

### 1. RuboCop configuration file

Put this into your `.rubocop.yml`:

```ruby
require: rubocop-rails-order_model_macros
```

Now you can run `rubocop` and it will automatically load the `RuboCop` `Rails/OrderModelMacros` cop together with the standard cops.

### 2. Command line

```
rubocop --require rubocop-rails-order_model_macros
```

### 3. Rake task

```ruby
RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-rails-order_model_macros'
end
```

## Configuring the cops

The [default configuration](config/default.yml) defines an outer group ordering, Rails macros to check, and inner group orderings for associations and validations.

```yaml
Rails/OrderModelMacros:
  Description: 'Sort macros methos in Rails models.'
  Enabled: true
  PreferredGroupOrdering:
    - default_scope
    - class_method
    - enum
    - association
    - validation
    - callback
    - delegate
    - rails
    - gem
    - custom
    - scope
  PreferredInnerGroupOrdering:
    association:
      - belongs_to
      - has_one
      - has_and_belongs_to_many
      - has_many
    validation:
      - validates
      - validate
      - with_options
  Rails:
    - accepts_nested_attributes_for
    - serialize
    - store_accessor
  Custom: null
  Gem: null
```



All of these may be customized. To only include a subset of groups, or to modify the order, define your own `PreferredGroupOrdering`. To add additional Rails macros, define a `Rails` array. Definitions overwrite defaults, so if you customize, be sure to copy over any desired types from the default set when applicable.

- Add custom macros to `Custom`.
- Add any Gem defined macros to `Gem`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/carolineartz/rubocop-rails-order_model_macros. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

