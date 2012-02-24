module BeautifulScaffoldModule
  def generate_fulltext_field(fields)
    fields.each{ |f|
      html, clear = htmlize(self[f], self[f + '_typetext'])
      self[f + '_fulltext'] = clear
    }
  end
  
  def htmlize(text, type)
    case type
      when 'bbcode' then
        require 'bb-ruby'
        html = text.bbcode_to_html
      when 'html' then
        html = text
      when 'textile' then
        html = RedCloth.new(text).to_html
      when 'markdown' then
        require 'rdiscount'
        html = RDiscount.new(text).to_html
      when 'wiki' then
        html = WikiCloth::Parser.new({:data => text}).to_html
      else
        html
    end
    return html, Sanitize.clean(html)
  end
end
