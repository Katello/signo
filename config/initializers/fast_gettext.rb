# config/initializers/fast_gettext.rb

locale_dir = File.join(File.dirname(__FILE__), '..', '..', 'locale')
default_available_locales = Rails.env.test? ? [] : Dir.entries(locale_dir).reject {|d| d =~ /(^\.|pot$)/ }

# no need to generate MO files for development mode
locale_type = Rails.env.development? ? :po : :mo
FastGettext.add_text_domain 'signo', :path => 'locale', :type => locale_type
FastGettext.default_available_locales = ['en'] + default_available_locales
FastGettext.default_text_domain = 'signo'
