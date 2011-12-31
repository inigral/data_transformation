require 'rails/generators'
require 'rails/generators/active_record'
require 'fileutils'

class TransformGenerator < ActiveRecord::Generators::Base
  def self.source_root
    File.dirname(__FILE__) + '/templates'
  end

  def create_transform_file
    create_transforms_folder
    migration_template "transform.rb", "db/transforms/#{file_name}.rb"
  end

  def create_transforms_folder
    FileUtils.mkdir("db/transforms") unless Dir.exists?("db/transforms")
  end
end
