= Beautiful Scaffold

Beautiful Scaffold is a gem which propose generators for a complete scaffold with paginate, sort and filter.
Fully customizable.
More info : http://www.beautiful-scaffold.com/
Demo : http://demo.beautiful-scaffold.com/

== Install

=== RubyOnRails 3.X

Add this in your Gemfile :
gem 'beautiful_scaffold', '0.2.7'

=== RubyOnRails 4.X

Add this in your Gemfile :
gem 'beautiful_scaffold', '~>0.3'

=== Next

And run
bundle install

== Usage

=== Scaffold

rails generate beautiful_scaffold model attr:type attr:type... [--namespace=name]

type available :
* integer
* float
* text
* string
* price
* color
* richtext
* wysiwyg

# Example : products
rails g beautiful_scaffold product name:string price:price tva:float description:richtext visible:boolean && rake db:migrate

# Example : admin products
rails g beautiful_scaffold product name:string price:price tva:float description:richtext overview_description:richtext visible:boolean --namespace=admin && rake db:migrate

=== Migration (Use Add[Field]To[ModelPluralize] syntax)

rails g beautiful_migration AddFieldToModels field:type

=== Locale (i18n) (Example)

Run rake db:migrate before rail g beautiful_locale (to get lastest attribute translation)

rails g beautiful_locale all
rails g beautiful_locale en
rails g beautiful_locale fr
rails g beautiful_locale de

=== Join Table (has_and_belongs_to_many relation)

rails g beautiful_jointable model1 model2

=== Install et Configure Devise (authentification) and Cancan (authorization)

rails g beautiful_devisecancan model

=== In views

==== Barcodes

Set code like this :
<span class="barcode" data-barcode="1234567890128" data-type-barcode="ean13"></span>

data-type-barcode can be :

codabar
code11 (code 11)
code39 (code 39)
code93 (code 93)
code128 (code 128)
ean8 (ean 8)
ean13 (ean 13)
std25 (standard 2 of 5 - industrial 2 of 5)
int25 (interleaved 2 of 5)
msi
datamatrix (ASCII + extended)

==== Chardinjs (overlay instructions)

Example : This button triggers chardinjs on element with 'menu' id.
<a href="#" class="bs-chardinjs" data-selector="#menu">Help Menu</a>

If you want display all chardinjs :
<a href="#" class="bs-chardinjs" data-selector="body">Help</a>

Just add class="bs-chardinjs" in a button / link for trigger chardinjs. Beautiful-Scaffold does the job !

For add instruction to element, read official documentation : https://github.com/heelhook/chardin.js#adding-data-for-the-instructions
