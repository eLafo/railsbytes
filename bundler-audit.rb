def do_bundle
  Bundler.with_original_env { run "bundle install" }
end

def print_green(heredoc)
  puts set_color heredoc, :green
end

def do_commit
  git :init
  git add: "."
  git commit: " -m 'Add bundler-audit patch-level verification' "
end

def puts_usage
  say "\nUsage:"
  say "`bin/bundler-audit check --update`"
end

say "\nApplying bundler-audit patch-level verification..."
inject_into_file 'Gemfile', after: 'group :development do' do
  <<-RUBY

  # bundler-audit provides patch-level verification for Bundled apps.
  gem "bundler-audit", require: false
  RUBY
end

do_bundle

run "bundle binstubs bundler-audit"
run "bin/bundler-audit check --update"

do_commit

print_green "\nAdded bundler-audit successfully!"
puts_usage