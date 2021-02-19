require 'test_helper'
require 'generators/beautiful_scaffold_generator'
require 'generators/beautiful_migration_generator'

# In order to run test : in Beautiful-Scaffold dir just run :
# rake test
#
# Source :
# https://fossies.org/linux/rails/railties/test/generators/shared_generator_tests.rb
# https://rossta.net/blog/testing-rails-generators.html

class BeautifulMigrationGeneratorTest < Rails::Generators::TestCase
  tests BeautifulScaffoldGenerator
  destination Rails.root.join('../tmp/dummyappmigration') # test/dummy/tmp/generators/dummyapp....

  setup do
    #puts "SETUP " * 100
    prepare_destination # Create tmp
    Dir.chdir(File.dirname(destination_root)) { # dans test/tmp
      system "rails new dummyappmigration --skip-test-unit --skip-spring --skip-bootsnap --skip-webpack-install --skip-javascript"
    }
  end

  # At the end of test
  teardown do
    Dir.chdir(File.dirname(destination_root)) {
      system 'rm -rf dummyappmigration'
    }
  end

  test "generator runs with relation" do
    self.class.generator_class = BeautifulScaffoldGenerator
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
      assert_match('<%= f.hidden_field("birthday(#{i+1}i)", value: @user.birthday&.send(meth), id: "user_birthday_input_#{i+1}i") %>', content)
    end

    ###############################
    # Migration with reference
    ###############################

    self.class.generator_class = BeautifulScaffoldGenerator
    run_generator 'sex label:string -f'.split(' ')
    self.class.generator_class = BeautifulMigrationGenerator
    run_generator 'AddSexToUsers sex:references -f'.split(' ')

    assert_file 'app/models/user.rb', /belongs_to :sex/
    assert_file 'app/models/sex.rb', /has_many :users, :dependent => :nullify/

    assert_file 'app/views/users/_form.html.erb' do |content|
      # Input family_id (foreign-key)
      assert_match('<%= f.collection_select :sex_id, Sex.all, :id, :caption, { :include_blank => true }, { :class => "form-control" } %>', content)
    end

  end
end
