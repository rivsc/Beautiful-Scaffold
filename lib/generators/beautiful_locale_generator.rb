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

    if localestr == 'all' then
      locale_to_process = availablelocale
    else
      locale_to_process << localestr
    end
    
    locale_to_process.each{ |temp_locale|
      filename = "beautiful_scaffold.#{temp_locale}.yml"
      gem_localepath = "app/locales/#{filename}"
      app_localepath = "config/locales/#{filename}"
      begin
        copy_file gem_localepath, app_localepath
      rescue
        say_status("Error", "This beautiful_locale #{localestr} doesn't exist !", :red)
      end

      rails_locale_file = "#{temp_locale}.yml"
      download_path = "https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/#{rails_locale_file}"
      begin
        get download_path, "config/locales/#{rails_locale_file}"
      rescue
        say_status("Error", "Error to download locale, verify if locale exist at : #{download_path}", :red)
      end
    }

    say_status("Warning", "/!\\ Remember to update your application.rb file !", :yellow)
  end

end
