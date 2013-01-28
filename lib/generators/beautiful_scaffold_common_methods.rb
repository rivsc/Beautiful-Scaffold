module BeautifulScaffoldCommonMethods
  require 'erb'

  private
  
  def namespace_for_class
    str = namespace_alone
    if not str.blank? then
      str = str.camelcase + '::'
    end
    return str
  end
  
  def namespace_for_route
    str = namespace_alone
    if not str.blank? then
      str = str.downcase + '_'
    end
    return str
  end
  
  def namespace_for_url
    str = namespace_alone
    if not str.blank? then
      str = str.downcase + '/'
    end
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

  def model_camelize
    model.camelize
  end

  def model_pluralize
    model.pluralize
  end

  def model_class
    model.camelize
  end
  
  # For the views
  def plural_table_name
    model_pluralize
  end
  def singular_table_name
    model
  end

  def available_views
    %w(index edit show new _form)
  end
  
  def attributes
    # https://raw.github.com/rails/rails/master/railties/lib/rails/generators/generated_attribute.rb
    return myattributes.map{ |a|
      require 'rails/generators/generated_attribute'
      Rails::Generators::GeneratedAttribute.new(*a.split(":"))
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
    gem('will_paginate')
    gem('ransack')
    gem('prawn', '1.0.0.rc1')
    gem('RedCloth')
    gem('bb-ruby')
    gem('bluecloth')
    gem('rdiscount')
    gem('sanitize')
  end

end
