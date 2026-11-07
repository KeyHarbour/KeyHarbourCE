namespace :db do
  desc "Force drop DB even if other connections exist"
  task force_reset: :environment do
    db_config = ActiveRecord::Base.connection_db_config
    db_name = db_config.database

    config = ActiveRecord::Base.configurations.configs_for(env_name: "development", name: "logs")
    db_name_log = db_config.database

    system %(psql -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '#{db_name}' AND pid <> pg_backend_pid();")
    system %(psql -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '#{db_name_log}' AND pid <> pg_backend_pid();")
    system "DISABLE_DATABASE_ENVIRONMENT_CHECK=1 rails db:migrate:reset"
  end
end
