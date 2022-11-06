def do_bundle
  Bundler.with_original_env { run "bundle install" }
end

def print_green(heredoc)
  puts set_color heredoc, :green
end

def do_commit
  git :init
  git add: "."
  git commit: " -m 'Adds rubocop' "
end

def do_config
  config = {
    "require" =>["rubocop-rails", "rubocop-rspec", "rubocop-faker", "rubocop-performance"],
    "AllCops" => {
      "NewCops" => "enable",
      "Exclude" => ["bin/*", "db/schema.rb"]
    },
    "Style/Documentation" => {
      "Enabled" => false
    },
    "Style/StringLiterals" => {
      "Enabled" => false
    },
    "Style/SymbolArray" => {
      "Enabled" => false
    },
  }

  current_config = File.exist?(".rubocop.yml") ? YAML.load_file(".rubocop.yml") : {}
  current_config ||= {}
  create_file ".rubocop.yml", config.deep_merge(current_config).to_yaml
end

say "\nApplying rubocop..."
inject_into_file 'Gemfile', after: 'group :development do' do
  <<-RUBY

  # rubocop is a tool to manage and configure Git hooks.
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-faker", require: false
  RUBY
end

do_bundle

do_config

if yes?("Do you want to run rubocop -a?")
  run("rubocop -a")
end

run("rubocop --auto-gen-config")

run "bundle binstubs rubocop"

do_commit
