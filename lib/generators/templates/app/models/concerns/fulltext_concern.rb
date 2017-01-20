module FulltextConcern
  extend ActiveSupport::Concern

  included do
    #########################
    #
    # Scopes
    # Relations
    # Filter
    #...
    #########################
    before_save :fulltext_field_processing
  end

  #########################
  # Méthode d'instance
  #########################
  def fulltext_field_processing
    # You can preparse with own things here
    generate_fulltext_field
  end

  def generate_fulltext_field
    fields = (self.class.fulltext_fields || [])
    fields.each{ |f|
      html, clear = htmlize(self[f], self[f + '_typetext'])
      self[f + '_fulltext'] = clear
    }
  end

  def htmlize(text, type)
    case type
      #when 'bbcode' then
      #  require 'bb-ruby'
      #  html = text.bbcode_to_html
      when 'html' then
        html = text
      #when 'textile' then
      #  html = RedCloth.new(text).to_html
      #when 'markdown' then
      #  require 'rdiscount'
      #  html = RDiscount.new(text).to_html
      #when 'wiki' then
      #  html = WikiCloth::Parser.new({:data => text}).to_html
      else
        html
    end
    return html, Sanitize.clean(html)
  end

  class_methods do
    #########################
    # Méthode de Class
    #########################
  end
end