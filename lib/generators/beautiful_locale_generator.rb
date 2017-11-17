# encoding : utf-8
class BeautifulLocaleGenerator < Rails::Generators::Base
  require 'beautiful_scaffold_common_methods'
  include BeautifulScaffoldCommonMethods

  source_root File.expand_path('../templates', __FILE__)

  argument :name, :type => :string, :desc => "type of locale : fr OR en OR de OR ja all..."

  class_option :mountable_engine, :default => nil

  def list_locales
    availablelocale = ["fr", "en", "ja"]

    localestr = name.downcase
    (localestr == 'all' ? availablelocale : [localestr])
  end
  
  def install_locale
    list_locales.each{ |temp_locale|
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

    app_name = (Rails.root || engine_opt)
    engine_or_apps = (Rails.application.class.parent_name || engine_opt).downcase
    prefix = engine_opt.blank? ? '' : "#{engine_opt.camelize}::"

    already_processed = {}
    hi18n = {}

    list_locales.each do |locale_str|
      locale = locale_str.downcase

      already_processed[locale] ||= {}

      filepath = File.join(app_name, 'config', 'locales', "#{engine_or_apps}.#{locale}.yml")
      begin
        if File.exist?(filepath)
          hi18n = YAML.load_file(filepath)
        end
      rescue
        puts "Error loading locale file (YAML invalid?) : #{filepath}"
      end

      hi18n[locale]                  ||= { 'app' => {} }
      hi18n[locale]['app']           ||= { 'models' => {} }
      hi18n[locale]['app']['models'] ||= {}

      # Feed data already translated
      hi18n[locale]['app']['models'].each do |modelname, hshtranslations|
        hshtranslations['bs_attributes'].each do |attr, translated_attr|
          already_processed[locale][attr] = translated_attr
        end
      end

      Dir.glob("app/models/**/*").each do |model_file|
        puts model_file

        next if File.directory?(model_file) or
          File.basename(model_file).first == '.' or
          model_file.include?('/concerns/') or
          model_file.include?('pdf_report.rb') or
          model_file.include?('application_record.rb')

        model = File.basename(model_file, File.extname(model_file))

        klass = "#{prefix}#{model}".camelize.constantize
        sorted_attr = klass.attribute_names.sort

        newmodel = !hi18n[locale]['app']['models'].has_key?(model)

        hi18n[locale]['app']['models'][model] ||= {
          'bs_caption'            => model,
          'bs_caption_plural'     => model.pluralize,
          'bs_attributes'         => {},
        }

        if newmodel then
          bs_caption = ""
          begin
            bs_caption = translate_string(locale, model)
          rescue Exception => e
            puts "Erreur traduction #{e.backtrace}"
            bs_caption = model
          end
          bs_caption_plural = ""
          begin
            bs_caption_plural = translate_string(locale, model.pluralize)
          rescue Exception => e
            puts "Erreur traduction #{e.backtrace}"
            bs_caption_plural = model.pluralize
          end

          hi18n[locale]['app']['models'][model]['bs_caption'] = bs_caption
          hi18n[locale]['app']['models'][model]['bs_caption_plural'] = bs_caption_plural
        end

        hi18n[locale]['app']['models'][model]['bs_attributes'] ||= {}

        sorted_attr.each do |k|
          # Si pas déjà renseigné
          if hi18n[locale]['app']['models'][model]['bs_attributes'][k].blank?
            # Si pas déjà traduit
            if already_processed[locale][k].blank?
              begin
                attr_translate = translate_string(locale, k)
                already_processed[locale][k] = attr_translate
              rescue
                puts "Plantage translate API"
                attr_translate = k
              end
            else
              attr_translate = already_processed[locale][k]
            end
          else
            # Récupère l'attribut traduit
            attr_translate = hi18n[locale]['app']['models'][model]['bs_attributes'][k]
          end

          hi18n[locale]['app']['models'][model]['bs_attributes'][k] = attr_translate
        end
      end

      File.unlink(filepath) if File.exist?(filepath)

      file = File.open(filepath, "w")
      file.write(hi18n.to_yaml)
      file.close
    end
  end

  private

  def translate_string(locale, str)
    # See http://www.microsofttranslator.com/dev/
    #
    if locale == "en"
      attr_translate = "#{str.gsub(/_/, " ")}"
    else
      url_domain = "api.mymemory.translated.net"
      url_query = "/get?q=#{str.gsub(/_/, "%20")}&langpair=en%7C#{locale}"

      json = JSON.parse(Net::HTTP.get(url_domain, url_query))
      attr_translate = json["responseData"]["translatedText"].strip.downcase
    end
    raise 'Free Limit' if attr_translate =~ /mymemory/

    return attr_translate
  end

end
