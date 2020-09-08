source "http://rubygems.org"

gemspec

gem "rails", "~> 6.0"

group :test do
  gem 'sqlite3'

  gems = {
      'will_paginate' => nil, # v 3.1.5
      'ransack' => nil, #'2.3.2',
      'jquery-ui-rails' => nil,
      'prawn' => nil, #'2.1.0',
      'prawn-table' => nil, #'0.2.2',
      'sanitize' => nil,
      'bootstrap' => '~> 4.3.1',
      'font-awesome-rails' => '4.7.0.5',
      'momentjs-rails' => '>= 2.9.0',
      'bootstrap4-datetime-picker-rails' => nil,
      'jquery-rails' => '4.3.1'
  }

  gems.each{ |gem_to_add, version|
    gem(gem_to_add, version)
  }
end

