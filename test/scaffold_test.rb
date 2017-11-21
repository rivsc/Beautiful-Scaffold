require 'bundler'
require 'thor'
require 'rails'
require 'rails/generators'
require 'minitest/autorun'

require_relative File.expand_path("../../lib/generators/beautiful_scaffold_generator", __FILE__)

ENV["RAILS_ENV"] = 'test'

class ScaffoldGeneratorTest < ::Rails::Generators::TestCase

  tests BeautifulScaffoldGenerator
  destination File.expand_path("../tmp/dummyapp", File.dirname(__FILE__))

  def create_generator_sample_app
    if !File.exist?(destination_root)
      puts "---> Create Dummy App #{destination_root}"
      FileUtils.cd(File.dirname(destination_root)) do
        system "rails new dummyapp --quiet --skip-bundle"
      end

      test_params = "User email:string birthday:datetime children:integer biography:text"

      run_generator test_params.split(' ')
    end
  end

  Minitest.after_run do
    FileUtils.rm_rf(destination_root)
  end

  setup do
    create_generator_sample_app
  end

  test "generates js css" do
    assert_file "app/assets/javascripts/application-bs.js"
    assert_file "app/assets/javascripts/beautiful_scaffold.js"
    assert_file "app/assets/javascripts/bootstrap-colorpicker.js"
    assert_file "app/assets/javascripts/bootstrap-datetimepicker-for-beautiful-scaffold.js"
    assert_file "app/assets/javascripts/bootstrap-wysihtml5.js"
  end

  test "generates model" do
    assert_file "app/models/user.rb" do |content|
      assert_match('self.permitted_attributes', content)
      #assert_match(/return #{test_params.split(' ')[1..-1]keys.map{ |k| ":#{k}"}.join(',')}/, content)
    end
  end

  test "generates controller" do
    assert_file "app/controllers/users_controller.rb" do |content|
      assert_match("session['fields']['user'] ||= (User.columns.map(&:name) - [\"id\"])[0..4]", content)
    end
  end

  test "generates initializer" do
    assert_file "config/initializers/ransack.rb" do |content|
      assert_match('Ransack.configure do |config|', content)
    end

    assert_file "config/initializers/link_renderer.rb" do |content|
      assert_match('class LinkRenderer < LinkRendererBase', content)
    end
  end

end
