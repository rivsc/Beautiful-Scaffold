require 'test_helper'
require 'generators/beautiful_scaffold_generator'
require 'generators/beautiful_storage_generator'

# In order to run test : in Beautiful-Scaffold dir just run :
# rake test
#
# Source :
# https://fossies.org/linux/rails/railties/test/generators/shared_generator_tests.rb
# https://rossta.net/blog/testing-rails-generators.html

class BeautifulStorageGeneratorTest < Rails::Generators::TestCase
  tests BeautifulScaffoldGenerator
  destination Rails.root.join('../tmp/dummyappstorage') # test/dummy/tmp/generators/dummyapp....

  setup do
    #puts "SETUP " * 100
    prepare_destination # Create tmp
    Dir.chdir(File.dirname(destination_root)) { # dans test/tmp
      system "rails new dummyappstorage --skip-test-unit --skip-spring --skip-bootsnap --skip-webpack-install --skip-javascript"
    }
  end

  # At the end of test
  teardown do
    Dir.chdir(File.dirname(destination_root)) {
      system 'rm -rf dummyappstorage'
    }
  end

  test "generator storage" do
    #######
    # App
    #######

    self.class.generator_class = BeautifulScaffoldGenerator
    run_generator 'user name:string firstname:string -s'.split(' ')
    assert_file 'app/models/user.rb'

    #######
    # Storage
    #######

    self.class.generator_class = BeautifulStorageGenerator
    run_generator 'user picture_file'.split(' ')

    assert_file 'app/models/user.rb' do |content|
      # ActiveStorage
      assert_match('has_one_attached :picture_file', content)
      # permitted attribute
      assert_match('return :picture_file', content)
    end

    assert_file 'app/views/users/_form.html.erb' do |content|
      assert_match('form_for(@user, multipart: true)', content)
      assert_match("<%= f.label :picture_file, t('app.models.user.bs_attributes.picture_file', :default => 'picture_file').capitalize, :class => 'control-label' %><br />", content)
      assert_match("<%= f.file_field :picture_file, direct_upload: true, :class => 'form-control' %>", content)
    end
    assert_file 'app/views/users/show.html.erb' do |content|
      assert_match('<%= image_tag @user.picture_file.variant(resize_to_limit: [100, 100]) %>', content)
    end
  end
end
