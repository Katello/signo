group :test, :development do
  gem 'minitest-rails'
end

group :test do
  # Requests stubbing
  gem 'webmock'
end
