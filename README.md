# Guard::JestRunner

Guard::JestRunner allows you to automatically run jest when you change a Javascript/ES6 file.

Unlike [guard-jest](https://rubygems.org/gems/guard-jest), this guard runs just as directed by your Guardfile, which allows you to use it in a group and use a Red-Green-Refactor process.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'guard-jest_runner'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install guard-jest_runner

## Usage

Please read [Guard usage doc](https://github.com/guard/guard#readme).

## Guardfile

For a typical Rails app with webpack:

``` ruby
guard :jest do
  watch(%r{app/javascript/(.+)\.js$}) { |m| "spec/javascript/#{m[1]}.test.js" }
  watch(%r{spec/javascript/.+\.js$})
end
```

(**Recommended**) pair up with guard-eslint to get a Red-Green-Refactor process:

```ruby
group :red_green_refactor_js, halt_on_fail: true do
  guard :jest_runner do
    watch(%r{app/javascript/(.+)\.js$}) { |m| "spec/javascript/#{m[1]}.test.js" }
    watch(%r{spec/javascript/.+\.js$})
  end

  guard :eslint, formatter: 'codeframe' do
    watch(%r{app/javascript/(.+)\.js$}) { |m| ""}
    watch(%r{spec/javascript/(.+)\.js$})
  end
end
```

### List of available options:

``` ruby
all_on_start: false                    # Run all specs after changed specs pass.
keep_failed: true                      # Keep failed files until they pass (add them to new ones)
cli: nil                               # Additional command-line options to pass to jest.
                                       # Don't use the '-f' or '--format' option here.
command: 'jest'                        # Specify a custom path to the jest command.
default_paths: ['**/*.js', '**/*.es6'] # The default paths that will be used for "all_on_start".
notification: true                     # Display notification always when jest completes.
                                       # If you want to notify only on failure, set to :failed.
print_result: true                     # Print the output of the jest run. Set to :failed
                                       # if you want to see only for the failed runs
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RobinDaugherty/guard-jest_runner.

* Please create a topic branch for every separate change you make.
* Make sure your patches are well-tested.
* Update the README to reflect your changes.
* Please **do not change** the version number.
* Open a pull request. 
