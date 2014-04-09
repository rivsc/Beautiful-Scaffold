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

      willpaginate_locale_file = "will_paginate.#{temp_locale}.yml"
      download_path = "https://raw.github.com/mislav/will_paginate/master/lib/will_paginate/locale/en.yml"
      begin
        get download_path, "config/locales/#{willpaginate_locale_file}"
        say_status("Warning", "You must modify Will_paginate locale at : Rails.root/config/locale/#{willpaginate_locale_file}", :red)
      rescue
        say_status("Error", "Error to download locale, verify if locale exist at : #{download_path}", :red)
      end
    }

    say_status("Warning", "/!\\ Remember to update your application.rb file !", :yellow)
  end

  def regenerate_app_locale
    require 'net/http'

    already_processed = { name.downcase => {}}

    filepath = File.join(Rails.root, 'config', 'locales', "#{Rails.application.class.parent_name.downcase}.#{name.downcase}.yml")
    begin
      hi18n                                   = YAML.load_file(filepath)
    rescue
      puts "Error loading locale file : #{filepath}"
    end

    hi18n                                 ||= { name.downcase => {} }
    hi18n[name.downcase]                  ||= { 'app' => {} }
    hi18n[name.downcase]['app']           ||= { 'models' => {} }
    hi18n[name.downcase]['app']['models'] ||= {}

    # Feed data already translated
    hi18n[name.downcase]['app']['models'].each{ |modelname,hshtranslations|
      hshtranslations['bs_attributes'].each{ |attr, translated_attr|
        already_processed[name.downcase][attr] = translated_attr
      }
    }

    Dir.glob("app/models/**/*").each { |model_file|
      puts model_file
      next if File.directory?(model_file) or File.basename(model_file).first == '.'
      model = File.basename(model_file, File.extname(model_file))
      klass = model.camelize.constantize

      begin
        sorted_attr = klass.attribute_names.sort
      rescue
        next
      end

      newmodel = !hi18n[name.downcase]['app']['models'].has_key?(model)

      hi18n[name.downcase]['app']['models'][model] ||= {
          'bs_caption'            => model,
          'bs_caption_plural'     => model.pluralize,
          'bs_attributes'         => {},
      }

      if newmodel then
        bs_caption          = (begin translate_string(name.downcase, model) rescue model end)
        bs_caption_plural   = (begin translate_string(name.downcase, model.pluralize) rescue model.pluralize end)

        hi18n[name.downcase]['app']['models'][model]['bs_caption'] = bs_caption
        hi18n[name.downcase]['app']['models'][model]['bs_caption_plural'] = bs_caption_plural
      end

      hi18n[name.downcase]['app']['models'][model]['bs_attributes'] ||= {}

      sorted_attr.each { |k|
        # Si pas déjà renseigné
        if hi18n[name.downcase]['app']['models'][model]['bs_attributes'][k].blank? then
          # Si pas déjà traduit
          if already_processed[name.downcase][k].nil? then
            begin
              attr_translate = translate_string(name.downcase, k)
              already_processed[name.downcase][k] = attr_translate
            rescue
              puts "Plantage translate API"
              attr_translate = k
            end
          else
            attr_translate = already_processed[name.downcase][k]
          end
        else
          # Récupère l'attribut traduit
          attr_translate = hi18n[name.downcase]['app']['models'][model]['bs_attributes'][k]
        end

        hi18n[name.downcase]['app']['models'][model]['bs_attributes'][k] = attr_translate
      }
    }

    File.unlink(filepath) if File.exist?(filepath)

    file = File.open(filepath, "w")
    file.write(hi18n.to_yaml)
    file.close
  end

  private

  def translate_string(locale, str)
    # See http://www.microsofttranslator.com/dev/
    #
    if locale == "en" then
      attr_translate = "#{str.gsub(/_/, " ")}"
    else
      url_domain    = "mymemory.translated.net"
      url_translate = "/api/get?q=to_translate&langpair=en%7C#{locale}"

      urlstr = url_translate.gsub(/to_translate/, str.gsub(/_/, "%20"))
      json = JSON.parse(Net::HTTP.get(url_domain, urlstr))
      attr_translate = json["responseData"]["translatedText"].strip.downcase
    end
    raise 'Free Limit' if attr_translate =~ /mymemory/

    return attr_translate
  end

end
