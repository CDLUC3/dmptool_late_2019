TranslationIO.configure do |config|
  #config.api_key        = '511c05a980334c93b740484cb6a3030f'
  #config.source_locale  = 'en'
  #config.target_locales = ['en-GB', 'en-US', 'fr-CA', 'ja', 'pt-BR', 'es']

  # Uncomment this if you don't want to use gettext
  # config.disable_gettext = true

  # Uncomment this if you already use gettext or fast_gettext
   config.locales_path = Rails.root.join('config', 'locale')

  # Find other useful usage information here:
  # https://github.com/translation/rails#readme

  # Additional keys for multi-domain
  config.multi_domain           = true
  config.domain_names           = ['app', 'dmptool']
  config.domain_api_keys        = ['699f534dde5440848007090f55c04e43',
                                   'a475835b00794d55a0d40304ed09e0bd']
  config.domain_source_locales  = ['en', 'en']
  config.domain_target_locales  = [['en-GB', 'en-US', 'fr-CA', 'ja', 'pt-BR', 'es'],
                                   ['en-GB', 'en-US', 'fr-CA', 'ja', 'pt-BR', 'es']]
  config.domain_folders         = [[],['app/views/branded/']]
end

if Language.table_exists?
  def default_locale
    Language.default.try(:abbreviation) || "en-GB"
  end

  def available_locales
    LocaleSet.new(
      Language.sorted_by_abbreviation.pluck(:abbreviation).presence || [default_locale]
    )
  end
else
  def default_locale
    Rails.application.config.i18n.available_locales.first || "en-GB"
  end

  def available_locales
    Rails.application.config.i18n.available_locales = LocaleSet.new(["en-GB", "en"])
  end
end


I18n.available_locales = Language.all.pluck(:abbreviation)

I18n.default_locale    = Language.default.try(:abbreviation) || "en-GB"
