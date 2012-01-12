module DataTransformation
  class Schema < DataTransformation::Transformation
    def self.define(info={})
      unless info[:version].blank?
        initialize_schema_migrations_table
        ActiveRecord::Base.connection.assume_migrated_upto_version(info[:version], info[:transforms_path])
      end
    end
  end
end
