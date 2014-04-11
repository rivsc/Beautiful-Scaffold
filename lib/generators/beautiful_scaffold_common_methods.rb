module BeautifulScaffoldCommonMethods
  require 'erb'

  private

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

  def model_camelize
    model.camelize
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
      if ['richtext', 'wysiwyg'].include?(t) then
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
      if ['richtext', 'wysiwyg'].include?(t) then
        fulltext_field << a
      end
    }
    return fulltext_field
  end

  def richtext_type
    return ["bbcode","html","text","wiki","textile","markdown"]
  end

  def require_gems
    # for jquery-ui add "2.3.0" version for jquery-rails
    #say_status("Warning", "Set 2.0.1 version for jquery-rails (for a good compatibility with beautiful_scaffold)", :yellow)

    gem('less-rails', :github => "CQQL/less-rails", :branch => 'less-2.5')
    gem('will_paginate')
    gem('ransack', :github => 'activerecord-hackery/ransack', :branch => 'rails-4.1')
    gem('polyamorous', :github => 'activerecord-hackery/polyamorous')
    gem('jquery-ui-rails')
    gem('prawn', '1.0.0')
    gem('RedCloth')
    gem('bb-ruby')
    gem('bluecloth')
    gem('rdiscount')
    gem('sanitize')
    gem('twitter-bootstrap-rails', :github => 'seyhunak/twitter-bootstrap-rails', :branch => 'bootstrap3')
    gem('chardinjs-rails')
  end

end
