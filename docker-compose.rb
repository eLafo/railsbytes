volumes = []

config = { "version" => "3.1" }

if File.exist?('docker-compose.yml')
  config = YAML.load_file('docker-compose.yml')
end

config["services"] ||=  {}
config["volumes"] ||= {}

if yes?("Do you want to add a postgres service?")
  config["volumes"]["postgres"] = {}
  config["services"]["postgres"] = {
    "image" => "postgres",
    "restart" => "always",
    "environment" => {
      "POSTGRES_USER" => app_name,
      "POSTGRES_PASSWORD" => app_name
    },
    "volumes" => ["postgres:/var/lib/postgresql"],
    "ports" => ["5432:5432"]
  }

  create_file 'config/database.yml' do <<~EOF
    default: &default
      adapter: postgresql
      encoding: unicode
      pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  
    development:
      <<: *default
      database: #{app_name}_development
      username: #{app_name}
      password: #{app_name}
      host: localhost
      port: 5432
  
    test:
      <<: *default
      database: #{app_name}_test
      username: #{app_name}
      password: #{app_name}
      host: localhost
      port: 5432
  
    production:
      <<: *default
      url: <%= ENV['DATABASE_URL'] %>
    EOF
  end  
end

if yes?("Do you want a redis service?")
  config["volumes"]["redis"] = {}
  config["services"]["redis"] = {
    "image" => "redis",
    "restart" => "always",
    "volumes" => ["redis:/data"],
    "ports" => ["6379:6379"],
  }
end

if yes?("Do you want a mailcatcher service?")
  config["services"]["mailcatcher"] = {
    "image" => "tophfr/mailcatcher",
    "ports" => ["1080:80", "25:25"]
  }
end

create_file "docker-compose.yml", config.to_yaml