def do_bundle
  Bundler.with_original_env { run "bundle install" }
end

def print_green(heredoc)
  puts set_color heredoc, :green
end

def do_commit
  git :init
  git add: "."
  git commit: " -m 'Adds overcommit' "
end

def do_config
  config = {
    "PostCheckout" => {
      "ALL" => {
        "quiet" => "false"
      },
      "BundleInstall" => {
        "enabled" => "true",
        "quiet" => "false"
      }
    },
    "PreCommit" => {},
    "PrePush" => {},
    "CommitMsg" => {
      "CapitalizedSubject" => {
        "enabled" => "false"
      }
    }
  }

  if yes?("Adds rubocop precommit?")
    config["PreCommit"]["RuboCop"] = {
      "enabled" => "true",
      "on_warn" => "fail",
      "command" => ["bundle", "exec", "rubocop"]
    }
  end

  if yes?("Adds bundler audit precommit?")
    config["PreCommit"]["BundleAudit"] = {
      "enabled" => "true",
      "on_warn" => "fail # Treat all warnings as failures",
      "command" => ["bundle", "audit", "check", "--update"]
    }
  end

  current_config = File.exist?(".overcommit.yml") ? YAML.load_file(".overcommit.yml") : {}
  current_config ||= {}
  create_file ".overcommit.yml", config.deep_merge(current_config).to_yaml
end

say "\nApplying overcommit..."
inject_into_file 'Gemfile', after: 'group :development do' do
  <<-RUBY

  # overcommit is a tool to manage and configure Git hooks.
  gem "overcommit", require: false
  RUBY
end

do_bundle

run "overcommit --install"

do_config

run "overcommit --sign"

do_commit
