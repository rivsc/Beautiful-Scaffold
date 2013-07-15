# encoding : utf-8
class BeautifulJointableGenerator < Rails::Generators::Base
  require 'beautiful_scaffold_common_methods'
  include BeautifulScaffoldCommonMethods

  source_root File.expand_path('../templates', __FILE__)

  argument :join_models, :type => :array, :default => [], :banner => "model model"
  
  def create_join_table
    if join_models.length != 2 then
      say_status("Error", "Error need two singular models : example : user product", :red)
    else
      sorted_model = join_models.sort

      # Generate migration
      migration_content = "
      create_table :#{sorted_model[0].pluralize}_#{sorted_model[1].pluralize}, :id => false do |t|
        t.integer :#{sorted_model[0]}_id
        t.integer :#{sorted_model[1]}_id
      end

      add_index :#{sorted_model[0].pluralize}_#{sorted_model[1].pluralize}, [:#{sorted_model[0]}_id, :#{sorted_model[1]}_id]
      "

      migration_name = "create_join_table_for_#{sorted_model[0]}_and_#{sorted_model[1]}"
      generate("migration", migration_name)

      filename = Dir.glob("db/migrate/*#{migration_name}.rb")[0]

      inject_into_file(filename, migration_content, :after => "def change")

      # Add habtm relation
      inject_into_file("app/models/#{sorted_model[0]}.rb", "\n  has_and_belongs_to_many :#{sorted_model[1].pluralize}", :after => "ActiveRecord::Base")
      inject_into_file("app/models/#{sorted_model[1]}.rb", "\n  has_and_belongs_to_many :#{sorted_model[0].pluralize}", :after => "ActiveRecord::Base")
      inject_into_file("app/models/#{sorted_model[0]}.rb", ":#{sorted_model[1]}_ids, ", :after => "attr_accessible ")
      inject_into_file("app/models/#{sorted_model[1]}.rb", ":#{sorted_model[0]}_ids, ", :after => "attr_accessible ")
    end
  end

end
