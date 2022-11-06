def do_bundle
  Bundler.with_original_env { run "bundle install" }
end

def do_commit
  git :init
  git add: "."
  git commit: " -m 'Adds solargraph' "
end

say "\nInstalling solargraph..."
inject_into_file 'Gemfile', after: 'group :development do' do
  <<-RUBY

  gem "solargraph"
  RUBY
end

do_bundle

run "bundle binstubs solargraph"

do_commit
