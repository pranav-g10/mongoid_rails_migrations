namespace :db do
  namespace :mongoid do
    unless Rake::Task.task_defined?("db:mongoid:drop")
      desc 'Drops all the collections for the database for the current Rails.env'
      task :drop => :environment do
        Mongoid.master.collections.each {|col| col.drop_indexes && col.drop unless ['system.indexes', 'system.users'].include?(col.name) }
      end
    end

    desc 'Current database version'
    task :version => :environment do
      puts Mongoid::Migrator.current_version.to_s
    end

    desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x. Turn off output with VERBOSE=false."
    task :migrate => :environment do
      Mongoid::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      Mongoid::Migrator.migrate(Mongoid::Migrator.migrations_path, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end

    namespace :migrate do
      desc  'Rollback the database one migration and re migrate up. If you want to rollback more than one step, define STEP=x. Target specific version with VERSION=x.'
      task :redo => :environment do
        if ENV["VERSION"]
          Rake::Task["db:mongoid:migrate:down"].invoke
          Rake::Task["db:mongoid:migrate:up"].invoke
        else
          Rake::Task["db:mongoid:rollback"].invoke
          Rake::Task["db:mongoid:migrate"].invoke
        end
      end

      desc 'Resets your database using your migrations for the current environment'
      task :reset => ["db:mongoid:drop", "db:mongoid:migrate"]

      desc 'Runs the "up" for a given migration VERSION.'
      task :up => :environment do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version
        Mongoid::Migrator.run(:up, Mongoid::Migrator.migrations_path, version)
      end

      desc 'Runs the "down" for a given migration VERSION.'
      task :down => :environment do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version
        Mongoid::Migrator.run(:down, Mongoid::Migrator.migrations_path, version)
      end
    end

    desc 'Rolls the database back to the previous migration. Specify the number of steps with STEP=n'
    task :rollback => :environment do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      Mongoid::Migrator.rollback(Mongoid::Migrator.migrations_path, step)
    end

    namespace :schema do
      task :load do
        # noop
      end
    end

    namespace :test do
      task :prepare do
        # Stub out for MongoDB
      end
    end
  end
end
