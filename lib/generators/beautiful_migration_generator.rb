# encoding : utf-8
class BeautifulMigrationGenerator < Rails::Generators::Base
  require 'beautiful_scaffold_common_methods'
  include BeautifulScaffoldCommonMethods

  #include Rails::Generators::ResourceHelpers

  source_root File.expand_path('../templates', __FILE__)

  argument :name, :type => :string, :desc => "Name of the migration CamelCase AddXXXToYYY"
  argument :myattributes, :type => :array, :default => [], :banner => "field:type field:type"
  class_option :namespace, :default => nil

  def install_gems
    require_gems
  end

  def add_field_for_fulltext
    @beautiful_attributes = myattributes.dup
    @fulltext_field = []
    myattributes.each{ |attr|
      a,t = attr.split(':')
      if ['richtext', 'wysiwyg'].include?(t) then
        # _typetext = {bbcode|html|text|wiki|textile|markdown}
        # _fulltext = text without any code
        @fulltext_field << [a + '_typetext', 'string'].join(':')
        @fulltext_field << [a + '_fulltext', 'text'].join(':')
      end
    }
  end

  def generate_model
    generate("migration", "#{name} #{beautiful_attr_to_rails_attr(true).join(' ')} #{@fulltext_field.join(' ')}")
  end

  def add_to_model
    myattributes.each{ |attr|
      a,t = attr.split(':')
      if ['references', 'reference'].include?(t) then
        inject_into_file("app/models/#{model}.rb", "\n  belongs_to :#{a}", :after => "ActiveRecord::Base")
        inject_into_file("app/models/#{a}.rb", "\n  has_many :#{model_pluralize}, :dependent => :nullify", :after => "ActiveRecord::Base")
        inject_into_file("app/models/#{a}.rb", ":#{model}_ids, ", :after => "attr_accessible ")
        a += "_id"
      end
      inject_into_file("app/models/#{model}.rb", ":#{a}, ", :after => "attr_accessible ")
    }
  end

  def generate_views
    commonpath = "app/views/#{namespace_for_url}#{model_pluralize}/"
    
    # Form
    inject_into_file("#{commonpath}_form.html.erb", render_partial("app/views/partials/_form_field.html.erb"), :before => "<!-- Beautiful_scaffold - AddField - Do not remove -->\n" )
    # Index
    inject_into_file("#{commonpath}index.html.erb", render_partial("app/views/partials/_index_batch.html.erb"), :before => "<!-- Beautiful_scaffold - AddField - Batch - Do not remove -->\n" )
    inject_into_file("#{commonpath}index.html.erb", render_partial("app/views/partials/_index_header.html.erb"), :before => "<!-- Beautiful_scaffold - AddField - Header - Do not remove -->\n" )
    inject_into_file("#{commonpath}index.html.erb", render_partial("app/views/partials/_index_column.html.erb"), :before => "<!-- Beautiful_scaffold - AddField - Column - Do not remove -->\n" )
    inject_into_file("#{commonpath}index.html.erb", render_partial("app/views/partials/_index_search.html.erb"), :before => "<!-- Beautiful_scaffold - AddField - Search - Do not remove -->\n" )
    # Show
    inject_into_file("#{commonpath}show.html.erb", render_partial("app/views/partials/_show_field.html.erb"), :before => "<!-- Beautiful_scaffold - AddField - Field - Do not remove -->\n" )    
  end

  private

  def model
    return name.scan(/^Add(.*)To(.*)$/).flatten[1].underscore.singularize
  end

end
