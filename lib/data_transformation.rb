require "data_transformation/version"
require 'data_transformation/transformer'
require "data_transformation/transformation"
require "data_transformation/schema"

module DataTransformation
	class Railtie < Rails::Railtie
		rake_tasks do
			load 'tasks/data_transformations.rake'
		end
	end
end
