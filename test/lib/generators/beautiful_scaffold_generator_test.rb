require 'test_helper'
require 'generators/beautiful_scaffold_generator'
require 'generators/beautiful_migration_generator'

# In order to run test : in Beautiful-Scaffold dir just run :
# rake test
#
# Source :
# https://fossies.org/linux/rails/railties/test/generators/shared_generator_tests.rb
# https://rossta.net/blog/testing-rails-generators.html

class BeautifulScaffoldGeneratorTest < Rails::Generators::TestCase
  tests BeautifulScaffoldGenerator
  destination Rails.root.join('../tmp/dummyapp') # test/dummy/tmp/generators/dummyapp....

  setup do
    #puts "SETUP " * 100
    prepare_destination # Create tmp
    Dir.chdir(File.dirname(destination_root)) { # dans test/tmp
      system "rails new dummyapp --skip-test-unit --skip-spring --skip-bootsnap --skip-webpack-install --skip-javascript"
    }
  end

  # At the end of test
  teardown do
    Dir.chdir(File.dirname(destination_root)) {
      system 'rm -rf dummyapp'
    }
  end

  test "generator runs without errors" do
    assert_nothing_raised do
      run_generator 'user email:string birthday:datetime children:integer biography:text -f'.split(' ')
    end
  end

  test "generator runs with relation" do
    run_generator 'family label:string -s'.split(' ')
    run_generator 'user email:string birthday:datetime children:integer biography:text family:references -f'.split(' ')

    assert_file 'app/models/user.rb'
    assert_file 'app/models/family.rb'

    assert_file 'app/models/user.rb', /belongs_to :family/
    assert_file 'app/models/family.rb', /has_many :users/

    assert_file 'app/models/user.rb' do |content|
      assert_match('self.permitted_attributes', content)
    end
    assert_file 'app/controllers/users_controller.rb' do |content|
      assert_match("session['fields']['user'] ||= (User.columns.map(&:name) - [\"id\"])[0..4]", content)
    end

    assert_file 'app/views/users/_form.html.erb' do |content|
      # Input family_id (foreign-key)
      assert_match('<%= f.collection_select :family_id, Family.all, :id, :caption, { :include_blank => true }, { :class => "form-control" } %>', content)
      # Label biography
      assert_match("<%= f.label :biography, t('app.models.user.bs_attributes.biography', :default => 'biography').capitalize, :class => \"control-label\" %>", content)
      # Input date (day)
      assert_match('<input type="hidden" name="user[birthday(3i)]" id="user_birthday_3i" value="<%= begin @user.birthday.day rescue "" end %>" />', content)
    end

  end

  test "generator runs with files" do
    run_generator 'user email:string birthday:datetime children:integer biography:text -f'.split(' ')

    ###############
    # Assets
    ###############
    #
    # js
    assert_file 'app/assets/javascripts/application-bs.js'
    assert_file 'app/assets/javascripts/beautiful_scaffold.js'
    assert_file 'app/assets/javascripts/bootstrap-colorpicker.js'
    assert_file 'app/assets/javascripts/bootstrap-datetimepicker-for-beautiful-scaffold.js'
    assert_file 'app/assets/javascripts/bootstrap-wysihtml5.js'
    assert_file 'app/assets/javascripts/a-wysihtml5-0.3.0.min.js'
    assert_file 'app/assets/javascripts/fixed_menu.js'
    assert_file 'app/assets/javascripts/jstree.min.js'
    assert_file 'app/assets/javascripts/jquery-barcode.js'
    assert_file 'app/assets/javascripts/tagit.js'
    #
    # css
    assert_file 'app/assets/stylesheets/application-bs.scss'
    assert_file 'app/assets/stylesheets/beautiful-scaffold.css.scss'
    assert_file 'app/assets/stylesheets/bootstrap-wysihtml5.css'
    assert_file 'app/assets/stylesheets/colorpicker.css'
    assert_file 'app/assets/stylesheets/tagit-dark-grey.css'

    ###############
    # Controllers
    ###############
    assert_file 'app/controllers/beautiful_controller.rb'
    assert_file 'app/controllers/users_controller.rb'

    ###############
    # Helpers
    ###############
    assert_file 'app/helpers/beautiful_helper.rb'
    assert_file 'app/helpers/users_helper.rb'

    ###############
    # Models
    ###############
    assert_file 'app/models/concerns/caption_concern.rb'
    assert_file 'app/models/concerns/default_sorting_concern.rb'
    assert_file 'app/models/concerns/fulltext_concern.rb'
    assert_file 'app/models/user.rb'
    assert_file 'app/models/pdf_report.rb'

    assert_file 'app/models/concerns/caption_concern.rb' do |content|
      assert_no_match('module Dummyapp', content)
      assert_no_match('end #endofmodule', content)
    end
    assert_file 'app/models/concerns/default_sorting_concern.rb' do |content|
      assert_no_match('module Dummyapp', content)
      assert_no_match('end #endofmodule', content)
    end
    assert_file 'app/models/concerns/fulltext_concern.rb' do |content|
      assert_no_match('module Dummyapp', content)
      assert_no_match('end #endofmodule', content)
    end

    ###############
    # Views
    ###############
    assert_file 'app/views/beautiful/dashboard.html.erb'
    assert_file 'app/views/layouts/_beautiful_menu.html.erb'
    assert_file 'app/views/layouts/_form_habtm_tag.html.erb'
    assert_file 'app/views/layouts/_mass_inserting.html.erb'
    assert_file 'app/views/layouts/_modal_columns.html.erb'
    assert_file 'app/views/layouts/beautiful_layout.html.erb'

    assert_file 'app/views/users/index.html.erb' do |content|
      assert_match(" User.columns", content)
      # Table td biography
      assert_match('<td <%= visible_column("user", "children") %> class="bs-col-children <%= align_attribute("integer") %>">', content)
      # Search form
      assert_match('<%= ransack_field("user", "birthday", f, "Birthday") %>', content)
      # Table th children
      assert_match('<th <%= visible_column("user", "email") %> class="bs-col-email">', content)
    end

    assert_file 'app/views/users/show.html.erb' do |content|
      assert_match("<b><%= t('app.models.user.bs_attributes.email', :default => 'email') %>:</b>", content)
    end

    assert_file 'app/views/users/_form.html.erb' do |content|
      # Label biography
      assert_match("<%= f.label :biography, t('app.models.user.bs_attributes.biography', :default => 'biography').capitalize, :class => \"control-label\" %>", content)
      # Input date (day)
      assert_match('<input type="hidden" name="user[birthday(3i)]" id="user_birthday_3i" value="<%= begin @user.birthday.day rescue "" end %>" />', content)
    end

    assert_file 'app/views/layouts/_beautiful_menu.html.erb' do |content|
      assert_match('<%= link_to t(\'app.models.user.bs_caption_plural\', :default => \'user\').capitalize, users_path, class: "nav-link #{(params[:controller] == "users" ? "active" : "")}" %>', content)
    end

    ###############
    # Migrations
    ###############
    migration = "CreateUsers"
    assert_migration 'db/migrate/create_users.rb', /class #{migration} < ActiveRecord::Migration\[[0-9.]+\]/

    # check precompile
    #assert_file 'config/initializers/assets.rb', /Rails\.application\.config\.assets\.precompile += \['application-bs\.css','application-bs\.js'\]/
    assert_file 'config/initializers/ransack.rb'

    assert_file 'config/initializers/link_renderer.rb' do |content|
      assert_match('class BootstrapLinkRenderer < LinkRenderer', content)
    end

    assert_file 'config/initializers/ransack.rb' do |content|
      assert_match('Ransack.configure do |config|', content)
    end
  end
end
