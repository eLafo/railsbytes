def do_bundle
  Bundler.with_original_env { run "bundle install" }
end

def do_commit
  git :init
  git add: "."
  git commit: " -m 'Adds annotate' "
end

say "\nInstalling annotate..."
inject_into_file 'Gemfile', after: 'group :development do' do
  <<-RUBY

  gem "annotate"
  RUBY
end

do_bundle

generate "annotate:install"

run "bundle binstubs annotate"

do_commit
