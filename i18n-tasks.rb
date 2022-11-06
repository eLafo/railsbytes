def do_bundle
  Bundler.with_original_env { run "bundle install" }
end

def do_commit
  git :init
  git add: "."
  git commit: " -m 'Adds i18n-tasks' "
end

say "\nInstalling i18n-tasks..."
inject_into_file 'Gemfile', after: 'group :development do' do
  <<-RUBY

  gem "i18n-tasks"
  RUBY
end

do_bundle

run "cp $(i18n-tasks gem-path)/templates/config/i18n-tasks.yml config/"
run "cp $(i18n-tasks gem-path)/templates/rspec/i18n_spec.rb spec/"

run "bundle binstubs i18n-tasks"

do_commit
