# Code Coverage

if "true".eql?ENV["COVERAGE"] and "test".eql?ENV["RAILS_ENV"]
  SimpleCov.start do
    merge_timeout 1500
    minimum_coverage 60

    add_filter '/spec/'
    add_filter '/config/'
    add_filter '/classes/'
    add_filter '/lib/tasks/'
    add_filter '/lib/assets/'
    add_filter '/lib/templates/'
    add_filter '/vendor/'
    add_filter '/features/'
    add_filter '/script/'
    add_filter '/doc/'
    add_filter '/public/'
    add_filter '/bin/'
    add_filter '/coverage/'
    add_filter '/log/'
    add_filter '/db/'
    add_filter '/META-INF/'
    add_filter '/controlled/'

    add_group 'Utilities' do |src_file|
        src_file.filename.include? 'lib/utility'
    end
    add_group 'DomainServices' do |src_file|
      ['app/domains','app/services','lib/factory'].any? do |item|
        src_file.filename.include? item
      end
    end
    add_group 'SecurityServices' do |src_file|
        src_file.filename.include? 'lib/secure'
    end
    add_group 'Models' do |src_file|
      ['app/models', 'app/beans'].any? do |item|
        src_file.filename.include? item
      end
    end
    add_group 'Views' do |src_file|
      ['app/views', 'app/helpers', 'app/mailers'].any? do |item|
        src_file.filename.include? item
      end
    end
    add_group "Controllers" do |src_file|
      src_file.filename.include?  "app/controllers"
    end
  end
end
