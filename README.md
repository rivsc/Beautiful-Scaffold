# Beautiful Scaffold for RubyOnRails

Beautiful Scaffold is a gem which propose generators for a complete scaffold with paginate, sort and filter.
Fully customizable.

[Demo](http://demo.beautiful-scaffold.com/)
[More info](http://www.beautiful-scaffold.com/)
[Changelog](https://raw.github.com/rivsc/Beautiful-Scaffold/master/CHANGELOG)

### Preview
[![ScreenShot](https://raw.github.com/mibamur/Beautiful-Scaffold/master/lib/beautiful-scaffold.png)](http://www.youtube.com/watch?v=_xTqBWaNwak)

## Install
Add this in your ```Gemfile```:

#### RubyOnRails 3.X 
```ruby
gem 'beautiful_scaffold', '0.2.7'
```
#### RubyOnRails 4.X
```ruby
gem 'beautiful_scaffold', github: 'rivsc/Beautiful-Scaffold'
```

#### Trobleshooting
```jquery-ui``` support only old version now
```ruby
gem 'jquery-rails', "2.0.1"
```
you must change your ```Gemfile```

### Next

And run
```bundle install```

### Dependencies
It all wiil install automatically after first usage ```rails generate beautiful_scaffold ...```
```ruby
gem "will_paginate"
gem "ransack", github: "ernie/ransack", branch: "rails-4"
gem "prawn", "1.0.0.rc2"
gem "RedCloth"
gem "bb-ruby"
gem "bluecloth"
gem "rdiscount"
gem "sanitize"
gem "twitter-bootstrap-rails"
gem "chardinjs-rails"
```

## Usage

### Scaffold

```rails generate beautiful_scaffold model attr:type attr:type... [--namespace=name]```

type available:
* integer
* float
* text
* string
* price
* color
* richtext
* wysiwyg

#### Example : products
```
rails generate beautiful_scaffold \
product name:string \
price:price \
tva:float \
description:richtext \
visible:boolean 
```
then
```
rake db:migrate
```

#### Example : admin products
```rails g beautiful_scaffold product name:string price:price tva:float description:richtext overview_description:richtext visible:boolean --namespace=admin && rake db:migrate```

#### Migration (Use Add[Field]To[ModelPluralize] syntax)

```rails g beautiful_migration AddFieldToModels field:type```

### Locale (i18n) (Example)

Run ```rake db:migrate``` before ```rail g beautiful_locale``` (to get lastest attribute translation)
```
rails g beautiful_locale all
rails g beautiful_locale en
rails g beautiful_locale fr
rails g beautiful_locale de
```
### Join Table (has_and_belongs_to_many relation)

```rails g beautiful_jointable model1 model2```

### Install et Configure Devise (authentification) and Cancan (authorization)

```rails g beautiful_devisecancan model```

### In views

#### Barcodes

Set code like this :
```html
<span class="barcode" data-barcode="1234567890128" data-type-barcode="ean13"></span>
```
data-type-barcode can be :
* codabar
* code11 (code 11)
* code39 (code 39)
* code93 (code 93)
* code128 (code 128)
* ean8 (ean 8)
* ean13 (ean 13)
* std25 (standard 2 of 5 - industrial 2 of 5)
* int25 (interleaved 2 of 5)
* msi
* datamatrix (ASCII + extended)

#### [Chardinjs](https://github.com/heelhook/chardin.js#adding-data-for-the-instructions) (overlay instructions)

Example : This button triggers chardinjs on element with 'menu' id.
```html
<a href="#" class="bs-chardinjs" data-selector="#menu">Help Menu</a>
```
If you want display all chardinjs :
```html
<a href="#" class="bs-chardinjs" data-selector="body">Help</a>
```
Just add ```<input class="bs-chardinjs" ...>``` in a button / link for trigger chardinjs. 

Beautiful-Scaffold does the job!

For add instruction to element, read official [Chardinjs](https://github.com/heelhook/chardin.js#adding-data-for-the-instructions) documentation:
