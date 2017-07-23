# Code Coverage

if "true".eql?ENV["COVERAGE"] and "test".eql?ENV["RAILS_ENV"]
  SimpleCov.start do
    merge_timeout 1500
    minimum_coverage 60

    add_filter '/bin/'
    add_filter '/classes/'
    add_filter '/config/'
    add_filter '/coverage/'
    add_filter '/controlled/'
    add_filter '/db/'
    add_filter '/doc/'
    add_filter '/lib/'
    add_filter '/log/'
    add_filter '/META-INF/'
    add_filter '/public/'
    add_filter '/spec/'
    add_filter '/vendor/'

    add_group 'Utility' do |src_file|
        src_file.filename.include? 'app/strategy/utility'
    end
    add_group 'Strategy' do |src_file|
      ['app/strategy/domains','app/strategy/services',
       'app/strategy/registry','app/strategy/providers',
       'app/strategy/processors', 'app/beans'].any? do |item|
        src_file.filename.include? item
      end
    end
    add_group 'Security' do |src_file|
      src_file.filename.include? 'app/strategy/secure'
    end
    add_group "Controllers" do |src_file|
      src_file.filename.include?  "app/controllers"
    end
    add_group "Models" do |src_file|
      src_file.filename.include?  "app/models"
    end
  end
end
