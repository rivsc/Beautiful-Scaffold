module BeautifulScaffoldCommonMethods
  require 'erb'

  private

  #############
  # Engine
  #############

  def engine_opt
    options[:mountable_engine].to_s
  end

  def engine_name
    engine_opt.blank? ? '' : "#{engine_opt}/"
  end

  def engine_camel
    options[:mountable_engine].camelize
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
    result = ERB.new(::File.binread(source), nil, '-').result(binding)
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

  def beautiful_attr_to_rails_attr(for_migration = false)
    newmyattributes = []
    myattributes.each{ |attr|
      a,t = attr.split(':')
      newt = t
      if ['wysiwyg'].include?(t) then
        newt = 'text'
      elsif t == 'price' then
        newt = 'float'
      elsif ['references', 'reference'].include?(t) and for_migration then
        a = a + '_id'
        newt = 'integer:index'
      elsif t == 'color' then
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

      if ['references', 'reference'].include?(t) then
        a = a + '_id'
      end

      newmyattributes << a
    }

    return newmyattributes
  end

  def fulltext_attribute
    fulltext_field = []
    myattributes.each{ |attr|
      a,t = attr.split(':')
      if ['wysiwyg'].include?(t) then
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
      'less-rails' => '2.8.0',
      'will_paginate' => nil, # v 3.1.5
      'ransack' => '1.8.2',
      'polyamorous' => '1.3.1',
      'jquery-ui-rails' => nil,
      'prawn' => '2.1.0',
      'prawn-table' => '0.2.2',
      'sanitize' => nil,
      'twitter-bootstrap-rails' => '3.2.2',
      'chardinjs-rails' => nil,
      'momentjs-rails' => '>= 2.9.0',
      'bootstrap3-datetimepicker-rails' => '~> 4.17.47'
    }

    # Si engine il faut mettre les gems dans le gemspec et faire le require
    if !Dir.glob('./*.gemspec').empty?
      puts "============> Engine : You must add gems to your main app \n #{gems.to_a.map{ |a| "gem '#{a[0]}'#{(a[1].nil? ? '' : ", '#{a[1]}'")} " }.join("\n")}"
    end

    gems.each{ |gem_to_add, version|
      gem(gem_to_add, version)
    }
  end

end
