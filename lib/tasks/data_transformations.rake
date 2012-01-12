require 'active_record/connection_adapters/abstract_adapter'
desc "Hacks in the transform to migrations"
task :hack_in_ar do
  class << ActiveRecord::Migrator
    alias_method :original_schema_migrations_table_name, :schema_migrations_table_name
    def schema_migrations_table_name
      ActiveRecord::Base.table_name_prefix + "schema_transforms" + ActiveRecord::Base.table_name_suffix
    end
  end

  ActiveRecord::ConnectionAdapters::SchemaStatements.module_eval do
    alias_method :original_initialize_schema_migrations_table, :initialize_schema_migrations_table
    def initialize_schema_migrations_table
      sm_table = ActiveRecord::Migrator.schema_migrations_table_name

      unless table_exists?(sm_table)
        create_table(sm_table, :id => false) do |schema_migrations_table|
          schema_migrations_table.column :version, :string, :null => false
        end
        add_index sm_table, :version, :unique => true,
          :name => "#{ActiveRecord::Base.table_name_prefix}unique_schema_transforms#{ActiveRecord::Base.table_name_suffix}"

        # Backwards-compatibility: if we find schema_info, assume we've
        # migrated up to that point:
        si_table = ActiveRecord::Base.table_name_prefix + 'schema_info' + ActiveRecord::Base.table_name_suffix

        if table_exists?(si_table)
          old_version = select_value("SELECT version FROM #{quote_table_name(si_table)}").to_i
          assume_migrated_upto_version(old_version)
          drop_table(si_table)
        end
      end
    end
  end
end

desc "Undoes the hack in Active Record for the migrations"
task :undo_hack_in_ar do
  class << ActiveRecord::Migrator
    alias_method :schema_migrations_table_name, :original_schema_migrations_table_name
  end

  ActiveRecord::ConnectionAdapters::SchemaStatements.module_eval do
    alias_method :initialize_schema_migrations_table, :original_initialize_schema_migrations_table
  end
end

namespace :db do
  desc "Transform the database (options: VERSION=x, VERBOSE=false)."
  task :transform => [:environment, :hack_in_ar] do
    DataTransformation::Transformation.verbose = ENV['VERBOSE'] ? ENV['VERBOSE'] == "true" : true
    DataTransformation::Transformer.transform('db/transforms/', ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
    Rake::Task["db:transform:dump"].invoke
  end

  namespace :transform do
    desc "Dump the Transform schema."
    task :dump => [:environment, :hack_in_ar] do
      filename = ENV['SCHEMA'] || "#{Rails.root}/db/transform_schema.rb"
      File.open(filename, 'w') do |f|
        version = DataTransformation::Transformer::current_version rescue nil
        path = DataTransformation::Transformer::migrations_path
        f.puts "DataTransformation::Schema.define(:transforms_path => #{path}, :version => #{version})"
      end
      Rake::Task['undo_hack_in_ar'].invoke
    end

    desc "Load the Transform schema."
    task :load => [:environment, :hack_in_ar] do
      filename = ENV['SCHEMA'] || "#{Rails.root}/db/transform_schema.rb"
      if File.exists?(filename)
        load(filename)
      else
        abort %{#{filename} doesn't exist yet. Run 'rake db:transform' to create it and then try again.}
      end
      Rake::Task['undo_hack_in_ar'].invoke
    end
  end
end
