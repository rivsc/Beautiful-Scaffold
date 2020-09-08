# encoding : utf-8
class BeautifulMigrationGenerator < Rails::Generators::Base
  require_relative 'beautiful_scaffold_common_methods'
  include BeautifulScaffoldCommonMethods

  #include Rails::Generators::ResourceHelpers

  source_root File.expand_path('../templates', __FILE__)

  argument :name, type: :string, desc: "Name of the migration (in CamelCase) AddXxxTo[Engine]Yyy (Yyy must be plural)"
  argument :myattributes, type: :array, default: [], banner: "field:type field:type (for bt relation model:references)"

  class_option :namespace, default: nil
  class_option :donttouchgem, default: nil
  class_option :mountable_engine, default: nil

  def install_gems
    if options[:donttouchgem].blank?
      require_gems
    end
  end

  def add_field_for_fulltext
    @beautiful_attributes = myattributes.dup
    @fulltext_field = []
    myattributes.each{ |attr|
      a,t = attr.split(':')
      if ['richtext', 'wysiwyg'].include?(t)
        # _typetext = {bbcode|html|text|wiki|textile|markdown}
        # _fulltext = text without any code
        @fulltext_field << [a + '_typetext', 'string'].join(':')
        @fulltext_field << [a + '_fulltext', 'text'].join(':')
      end
    }
  end

  def generate_model
    generate("migration", "#{name} #{beautiful_attr_to_rails_attr.join(' ')} #{@fulltext_field.join(' ')}")
  end

  def add_to_model
    add_relation
  end

  def generate_views
    commonpath = "app/views/#{engine_name}#{namespace_for_url}#{model_pluralize}/"
    
    # Form
    inject_into_file("#{commonpath}_form.html.erb", render_partial("app/views/partials/_form_field.html.erb"), :before => "<!-- Beautiful_scaffold - AddField - Do not remove -->\n" )
    # Index
    inject_into_file("#{commonpath}index.html.erb", render_partial("app/views/partials/_index_batch.html.erb"), :before => "<!-- Beautiful_scaffold - AddField - Batch - Do not remove -->\n" )
    inject_into_file("#{commonpath}index.html.erb", render_partial("app/views/partials/_index_header.html.erb"), :before => "<!-- Beautiful_scaffold - AddField - Header - Do not remove -->\n" )
    inject_into_file("#{commonpath}index.html.erb", render_partial("app/views/partials/_index_column.html.erb"), :before => "<!-- Beautiful_scaffold - AddField - Column - Do not remove -->\n" )
    inject_into_file("#{commonpath}index.html.erb", render_partial("app/views/partials/_index_search.html.erb"), :before => "<!-- Beautiful_scaffold - AddField - Search - Do not remove -->\n" )
    inject_into_file("#{commonpath}index.html.erb", myattributes.map{ |attr| a,t = attr.split(':');"'#{a}'" }.join(',') + ',', :after => ":model_columns => [" )
    # Show
    inject_into_file("#{commonpath}show.html.erb", render_partial("app/views/partials/_show_field.html.erb"), :before => "<!-- Beautiful_scaffold - AddField - Field - Do not remove -->\n" )    
  end

  private

  def model
    return name.scan(/^Add(.*)To(.*)$/).flatten[1].underscore.singularize.gsub("#{options[:mountable_engine].underscore}_",'')
  end

end
