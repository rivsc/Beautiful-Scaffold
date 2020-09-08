require 'test_helper'
require 'generators/beautiful_scaffold_generator'

class BeautifulScaffoldEngineGeneratorTest < Rails::Generators::TestCase
  tests BeautifulScaffoldGenerator
  destination Rails.root.join('../tmp/dummyengineapp') # du coup test/tmp/generators/dummyapp....

  setup do
    prepare_destination # Create tmp
    Dir.chdir(File.dirname(destination_root)) { # dans test/tmp
      system "rails plugin new dummyengineapp --mountable --skip-test-unit --skip-spring --skip-bootsnap --skip-webpack-install --skip-javascript"
    }
  end

  # At the end of test
  teardown do
    Dir.chdir(File.dirname(destination_root)) {
      system 'rm -rf dummyengineapp'
    }
  end

  test "generator runs with relation" do
    run_generator 'family label:string --mountable-engine=dummyengineapp -s'.split(' ')
    run_generator 'user email:string birthday:datetime children:integer biography:text family:references --mountable-engine=dummyengineapp -f'.split(' ')

    ###########
    # Models
    ###########

    assert_file 'app/models/dummyengineapp/user.rb'
    assert_file 'app/models/dummyengineapp/family.rb'

    assert_file 'app/models/dummyengineapp/user.rb', /belongs_to :family/
    assert_file 'app/models/dummyengineapp/family.rb', /has_many :users/

    assert_file 'app/models/dummyengineapp/user.rb' do |content|
      assert_match('self.permitted_attributes', content)
    end

    assert_file 'app/models/dummyengineapp/user.rb' do |content|
      assert_match('self.permitted_attributes', content)
    end

    #############
    # Concerns
    #############

    assert_file 'app/models/concerns/dummyengineapp/caption_concern.rb'
    assert_file 'app/models/concerns/dummyengineapp/default_sorting_concern.rb'
    assert_file 'app/models/concerns/dummyengineapp/fulltext_concern.rb'

    assert_file 'app/models/concerns/dummyengineapp/caption_concern.rb' do |content|
      assert_match('module Dummyengineapp', content)
      assert_match('end #endofmodule', content)
    end
    assert_file 'app/models/concerns/dummyengineapp/default_sorting_concern.rb' do |content|
      assert_match('module Dummyengineapp', content)
      assert_match('end #endofmodule', content)
    end
    assert_file 'app/models/concerns/dummyengineapp/fulltext_concern.rb' do |content|
      assert_match('module Dummyengineapp', content)
      assert_match('end #endofmodule', content)
    end

    ###############
    # Views
    ###############
    assert_file 'app/views/dummyengineapp/beautiful/dashboard.html.erb'
    assert_file 'app/views/layouts/dummyengineapp/_beautiful_menu.html.erb'
    assert_file 'app/views/layouts/dummyengineapp/_form_habtm_tag.html.erb'
    assert_file 'app/views/layouts/dummyengineapp/_mass_inserting.html.erb'
    assert_file 'app/views/layouts/dummyengineapp/_modal_columns.html.erb'
    assert_file 'app/views/layouts/dummyengineapp/beautiful_layout.html.erb'

    assert_file 'app/controllers/dummyengineapp/users_controller.rb' do |content|
      assert_match("session['fields']['user'] ||= (User.columns.map(&:name) - [\"id\"])[0..4]", content)
    end

    assert_file 'app/views/dummyengineapp/users/index.html.erb' do |content|
      assert_match("Dummyengineapp::User.columns", content)
    end

    assert_file 'app/views/dummyengineapp/users/index.html.erb' do |content|
      assert_match("Dummyengineapp::User.columns", content)
    end

    assert_file 'app/views/dummyengineapp/families/index.html.erb' do |content|
      assert_match('render :partial => "layouts/dummyengineapp/mass_inserting"', content)
      assert_match('render :partial => "layouts/dummyengineapp/modal_columns", :locals => { :engine_name => \'dummyengineapp\'', content)
      assert_match('<% if Dummyengineapp::Family.columns.map(&:name).include?("family_id") %>', content)
      assert_match('', content)
      assert_match('', content)
    end

    assert_file 'app/views/dummyengineapp/families/treeview.html.erb' do |content|
      assert_match('Dummyengineapp::Family.select(:id).all', content)
    end

    assert_file 'app/views/dummyengineapp/users/_form.html.erb' do |content|
      assert_match('<%= f.collection_select :family_id, Dummyengineapp::Family.all, :id, :caption, { :include_blank => true }, { :class => "form-control" } %>', content)
    end
  end
end
