require 'test_helper'
require 'generators/beautiful_scaffold_generator'
require 'generators/beautiful_sorcery_generator'
require 'generators/beautiful_cancancan_generator'

# In order to run test : in Beautiful-Scaffold dir just run :
# rake test
#
# Source :
# https://fossies.org/linux/rails/railties/test/generators/shared_generator_tests.rb
# https://rossta.net/blog/testing-rails-generators.html

class BeautifulLoginLogoutGeneratorTest < Rails::Generators::TestCase
  tests BeautifulScaffoldGenerator
  destination Rails.root.join('../tmp/dummyappsorcery') # test/dummy/tmp/generators/dummyapp....

  setup do
    #puts "SETUP " * 100
    prepare_destination # Create tmp
    Dir.chdir(File.dirname(destination_root)) { # dans test/tmp
      system "rails new dummyappsorcery --skip-test-unit --skip-spring --skip-bootsnap --skip-webpack-install --skip-javascript"
    }
  end

  # At the end of test
  teardown do
    #Dir.chdir(File.dirname(destination_root)) {
    #  system 'rm -rf dummyappsorcery'
    #}
  end

  test "generator sorcery cancancan" do
    #######
    # App
    #######

    self.class.generator_class = BeautifulScaffoldGenerator
    run_generator 'family label:string -s'.split(' ')
    assert_file 'app/models/family.rb'

    run_generator 'user email:string -s'.split(' ')
    assert_file 'app/models/user.rb'

    #######
    # Sorcery
    #######

    self.class.generator_class = BeautifulSorceryGenerator
    run_generator []

    assert_file 'app/models/user.rb' do |content|
      assert_match('authenticates_with_sorcery!', content)
    end
    assert_file 'app/controllers/users_controller.rb' do |content|
      assert_match("def activate", content)
    end
    assert_file 'app/controllers/user_sessions_controller.rb' do |content|
      assert_match("login(params[:email], params[:password])", content)
    end

    assert_file 'app/views/user_mailer/activation_needed_email.fr.html.erb'
    assert_file 'app/views/user_mailer/activation_needed_email.fr.text.erb'
    assert_file 'app/views/user_mailer/activation_success_email.fr.html.erb'
    assert_file 'app/views/user_mailer/activation_success_email.fr.text.erb'

    assert_file 'app/views/user_mailer/activation_needed_email.en.html.erb'
    assert_file 'app/views/user_mailer/activation_needed_email.en.text.erb'
    assert_file 'app/views/user_mailer/activation_success_email.en.html.erb'
    assert_file 'app/views/user_mailer/activation_success_email.en.text.erb'

    assert_file 'app/views/user_sessions/_form.html.erb'
    assert_file 'app/views/user_sessions/new.html.erb'

    assert_file 'app/views/users/_form.html.erb' do |content|
      assert_match('f.password_field :password, :class => "form-control"', content)
      assert_match('f.password_field :password_confirmation, :class => "form-control"', content)
    end

    assert_file 'app/views/layouts/beautiful_layout.html.erb' do |content|
      assert_match("<%= render :partial => 'layouts/login_logout_register' %>", content)
    end

    assert_file 'config/initializers/sorcery.rb'
    assert_file 'config/initializers/sorcery.rb' do |content|
      assert_match("user.user_activation_mailer = UserMailer", content)
    end

    #######
    # Cancancan
    #######

    self.class.generator_class = BeautifulCancancanGenerator
    run_generator []

    assert_file 'app/models/ability.rb'

    assert_file "app/controllers/application_controller.rb" do |content|
      assert_match("rescue_from CanCan::AccessDenied do |exception|", content)
    end
  end
end
