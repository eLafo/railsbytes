def do_bundle
  Bundler.with_original_env { run "bundle install" }
end

def do_commit
  git :init
  git add: "."
  git commit: " -m 'Adds yard' "
end

say "\nInstalling yard..."
inject_into_file 'Gemfile', after: 'group :development do' do
  <<-RUBY

  gem "yard"
  RUBY
end

do_bundle

run "bundle binstubs yard"

do_commit
