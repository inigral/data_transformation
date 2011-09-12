module DataTransformation
	class Schema < DataTransformation::Transformation
		def self.define(info={})
			unless info[:version].blank?
				initialize_schema_migrations_table
       	assume_migrated_upto_version(info[:version], DataTransformation::Transformer.migrations_path)
			end
		end
	end
end
