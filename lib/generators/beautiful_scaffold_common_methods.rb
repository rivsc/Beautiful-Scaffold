module BeautifulScaffoldCommonMethods
  require 'erb'

  private

  #############
  # Engine
  #############

  def engine_opt
    options[:mountable_engine].to_s.downcase
  end

  def engine_name
    engine_opt.blank? ? '' : "#{engine_opt}/"
  end

  def engine_camel
    options[:mountable_engine].to_s.camelize
  end

  #############
  # Namespace
  #############

  def namespace_for_class
    str = namespace_alone
    str = str.camelcase + '::' if not str.blank?
    return str
  end

  def namespace_for_route
    str = namespace_alone
    str = str.downcase + '_' if not str.blank?
    return str
  end

  def namespace_for_url
    str = namespace_alone
    str = str.downcase + '/' if not str.blank?
    return str
  end

  def namespace_alone
    return options[:namespace].to_s.downcase
  end

  def render_partial(path)
    source  = File.expand_path(find_in_source_paths(path.to_s))
    result = ERB.new(::File.binread(source), trim_mode: '-').result(binding)
    return result
  end

  ############
  # Models
  ############

  def model
    model_opt.underscore
  end

  def model_camelize
    model.camelize
  end

  def model_with_engine_camelize
    (engine_name.blank? ? model.camelize : "#{engine_camel}::#{model_camelize}")
  end

  def model_pluralize
    model.pluralize
  end

  def model_class
    model.camelize
  end

  ############
  # Table
  ############

  def plural_table_name
    model_pluralize
  end
  def singular_table_name
    model
  end

  ############
  # I18n
  ############

  def attribute_path_i18n(model, attribute)
    "app.models.#{model}.bs_attributes.#{attribute}"
  end

  def model_path_i18n(model)
    "app.models.#{model}.bs_caption"
  end

  def model_p_path_i18n(model)
    "app.models.#{model}.bs_caption_plural"
  end

  def i18n_t_a(model, attribute)
    "t('#{attribute_path_i18n(model, attribute)}', :default => '#{attribute}')"
  end

  def i18n_t_m(model)
    "t('#{model_path_i18n(model)}', :default => '#{model}')"
  end

  def i18n_t_m_p(model)
    "t('#{model_p_path_i18n(model)}', :default => '#{model}')"
  end

  def available_views
    %w(index edit show new _form)
  end

  def attributes
    # https://raw.github.com/rails/rails/master/railties/lib/rails/generators/generated_attribute.rb
    require 'rails/generators/generated_attribute'
    return myattributes.map{ |a|
      attr, type = a.split(":")
      Rails::Generators::GeneratedAttribute.new(attr, type.to_sym)
    }
  end

  def beautiful_attr_to_rails_attr #(for_migration = false)
    newmyattributes = []
    myattributes.each{ |attr|
      a,t = attr.split(':')
      newt = t

      # Special columns
      if ['wysiwyg'].include?(t)
        newt = 'text'
      elsif t == 'price'
        newt = 'float'
      elsif ['references', 'reference'].include?(t) # Because Rails generate corrupted files (migrations)
        a = "#{a}_id"
        newt = 'integer:index'
      elsif t == 'color'
        newt = 'string'
      end

      newmyattributes << [a, newt].join(':')
    }

    return newmyattributes
  end

  def attributes_without_type
    newmyattributes = []
    myattributes.each{ |attr|
      a,t = attr.split(':')

      if ['references', 'reference'].include?(t)
        a = a + '_id'
      end

      # Add the typetext to permitted_attr
      if t == 'wysiwyg'
        newmyattributes << "#{a}_typetext"
      end

      newmyattributes << a
    }

    return newmyattributes
  end

  def fulltext_attribute
    fulltext_field = []
    myattributes.each{ |attr|
      a,t = attr.split(':')
      if ['wysiwyg'].include?(t)
        fulltext_field << a
      end
    }
    return fulltext_field
  end

  def richtext_type
    return ["html","text"]
  end

  def require_gems
    gems = {
      'will_paginate' => nil, # v 3.1.5
      'ransack' => nil, #'2.3.2',
      'jquery-ui-rails' => nil,
      'prawn' => nil, #'2.1.0',
      'prawn-table' => nil, #'0.2.2',
      'sanitize' => nil,
      #'twitter-bootstrap-rails' => '3.2.2', # Bootstrap 3 for Rails 6+
      'bootstrap' => '~> 4.3.1', # Bootstrap 4 for Rails 6+
      'font-awesome-sass' => '~> 5.13.0',
      'momentjs-rails' => '>= 2.9.0',
      'bootstrap4-datetime-picker-rails' => nil,
      'jquery-rails' => '4.3.1',
      'jstree-rails-4' => '3.3.8'
    }

    # Si engine il faut mettre les gems dans le gemspec et faire le require
    if !Dir.glob('./*.gemspec').empty?
      puts "============> Engine : You must add gems to your main app \n #{gems.to_a.map{ |a| "gem '#{a[0]}'#{(a[1].nil? ? '' : ", '#{a[1]}'")} " }.join("\n")}"
    end

    gemfile_content = File.read('Gemfile')
    gems.each{ |gem_to_add, version|
      # Bug add at every times, need to check if already present
      if !gemfile_content.include?(gem_to_add)
        gem(gem_to_add, version)
      end
    }
  end

  def add_relation
    myattributes.each{ |attr|
      a,t = attr.split(':')

      foreign_key = a

      if ['references', 'reference'].include?(t)
        foreign_key = "#{a}_id"

        # question (model) belongs_to user (a)
        inject_into_file("app/models/#{engine_name}#{model}.rb", "\n  belongs_to :#{a}, optional: true", :after => "ApplicationRecord")
        inject_into_file("app/models/#{engine_name}#{a}.rb", "\n  has_many :#{model_pluralize}, :dependent => :nullify", :after => "ApplicationRecord")
      end

      inject_into_file("app/models/#{engine_name}#{model}.rb", ":#{foreign_key},", :after => "def self.permitted_attributes\n    return ")
    }
  end

end
