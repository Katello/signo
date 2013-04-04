# config/initializers/fast_gettext.rb
FastGettext.add_text_domain 'app', :path => 'locale', :type => :po
#FastGettext.default_available_locales = ['en','de'] #all you want to allow
FastGettext.default_text_domain = 'app'