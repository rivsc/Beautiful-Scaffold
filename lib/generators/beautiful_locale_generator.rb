# encoding : utf-8
class BeautifulLocaleGenerator < Rails::Generators::Base
  require 'beautiful_scaffold_common_methods'
  include BeautifulScaffoldCommonMethods

  source_root File.expand_path('../templates', __FILE__)

  argument :name, :type => :string, :desc => "type of locale : fr OR en OR de OR all..."
  
  def install_locale
    availablelocale = ["fr", "en"]
    
    localestr = name.downcase
    
    locale_to_process = []
    if availablelocale.include?(localestr) then
      locale_to_process << localestr
    elsif localestr == 'all' then
      locale_to_process = availablelocale
    else
      puts "This locale #{localestr} doesn't exist !"
    end
    
    locale_to_process.each{ |temp_locale|
      filename = "beautiful_scaffold.#{temp_locale}.yml"
      gem_localepath = "app/locales/#{filename}"
      app_localepath = "config/locales/#{filename}"
      copy_file gem_localepath, app_localepath
    }
    
    puts "/!\\ Remember to download rails locale and update your application.rb file !"
  end

end
