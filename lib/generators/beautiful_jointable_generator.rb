# encoding : utf-8
class BeautifulJointableGenerator < Rails::Generators::Base
  require_relative 'beautiful_scaffold_common_methods'
  include BeautifulScaffoldCommonMethods

  source_root File.expand_path('../templates', __FILE__)

  argument :join_models, :type => :array, :default => [], :banner => "Two model names singular downcase (ex: product family)"

  class_option :mountable_engine, default: nil
  
  def create_join_table
    if join_models.length != 2 then
      say_status("Error", "Error need two singular models : example : user product", :red)
    else
      sorted_model = join_models.sort

      prefix_str = ''
      if engine_name.present?
        prefix_str = "#{engine_opt}_"
      end

      join_table_name = "#{prefix_str}#{sorted_model[0].pluralize}_#{sorted_model[1].pluralize}"

      # Generate migration
      migration_content = "
      create_table :#{join_table_name}, :id => false do |t|
        t.integer :#{sorted_model[0]}_id
        t.integer :#{sorted_model[1]}_id
      end

      add_index :#{join_table_name}, [:#{sorted_model[0]}_id, :#{sorted_model[1]}_id]
      "

      migration_name = "create_join_table_for_#{sorted_model[0]}_and_#{sorted_model[1]}"
      generate("migration", migration_name)

      filename = Dir.glob("db/migrate/*#{migration_name}.rb")[0]

      inject_into_file(filename, migration_content, :after => "def change")

      # Add habtm relation
      inject_into_file("app/models/#{engine_name}#{sorted_model[0]}.rb", "\n  #{engine_name.present? ? '  ' : ''}has_and_belongs_to_many :#{sorted_model[1].pluralize}", :after => "ApplicationRecord")
      inject_into_file("app/models/#{engine_name}#{sorted_model[1]}.rb", "\n  #{engine_name.present? ? '  ' : ''}has_and_belongs_to_many :#{sorted_model[0].pluralize}", :after => "ApplicationRecord")
      inject_into_file("app/models/#{engine_name}#{sorted_model[0]}.rb", "{ :#{sorted_model[1]}_ids => [] }, ", :after => "permitted_attributes
      return ")
      inject_into_file("app/models/#{engine_name}#{sorted_model[1]}.rb", "{ :#{sorted_model[0]}_ids => [] }, ", :after => "permitted_attributes
      return ")
    end
  end

  def add_habtm_field_in_forms
    models = join_models.sort

    2.times do
      html = "<%=
    render :partial => 'layouts/#{engine_name}form_habtm_tag', :locals => {
      :model_class => @#{models[0]},
      :model_name => '#{models[0]}',
      :plural_model_name => '#{models[0].pluralize}',
      :linked_model_name => '#{models[1]}',
      :plural_linked_model_name => '#{models[1].pluralize}',
      :namespace_bs => '',
      :engine_bs => '#{engine_opt}',
      :field_to_search_for_linked_model => 'name',
      :attr_to_show => 'caption',
      :f => f
  } %>"

      inject_into_file("app/views/#{engine_name}#{models[0].pluralize}/_form.html.erb", html, :before => "<!-- Beautiful_scaffold - AddField - Do not remove -->")
      models = models.reverse
    end
  end
end
