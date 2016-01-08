# spec/support/test_data_serializers.rb
#

module TestDataSerializers

  # Serializes object to yaml file
  def write_test_data object, file_name
    fname = "#{Rails.root}/spec/factories/#{file_name}.yml"
    fname = "#{Rails.root}/spec/factories/last_test_data.yml" unless fname.present?
    raise ArgumentError, "File exists '#{fname}' -- delete the current one, or use a different name" if File.exist?(fname)
    raise ArgumentError, "Method requires an object as first params. " unless object.present?
    File.open(fname, "w") do |file|
      YAML::dump(object, file)
    end
  end

  # Restores object from yaml file
  def restore_test_data file_name
    fname = "#{Rails.root}/spec/factories/#{file_name}.yml"
    fname = "#{Rails.root}/spec/factories/last_test_data.yml" unless fname.present?
    YAML::load( IO.read(fname) )
  end

  def get_uploaded_test_file()
    content = "image/png"
    headers = {name: "auto[1-20b-files][]"}
    temp = ""
    file = Tempfile.open(["image_file",".png"])
    file.binmode
    file.write(IO.binread(Rails.root.join('spec', 'factories', "rails_png_upload_test_file.png")))
    file.flush
    file.rewind
    # do not close it -- user will close this file
    ActionDispatch::Http::UploadedFile.new(tempfile: file, filename: "rails_png_upload_test_file.png", head: headers, type: content)
  end

end
