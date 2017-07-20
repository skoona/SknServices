##
# File: app/strategy/processors/commands_base.rb
#
# Common Base for all Single Task Processsors
#

module Processors

  class NotReadyError < StandardError
  end


  class CommandBase
    include ::Registry::ObjectStorageService

    def self.inherited(klass)
      klass.processor_type = klass.name
      super
    end

    def self.processor_type
      @processor_prefix
    end

    def self.processor_type=(klass_name)
      @processor_prefix = klass_name
    end

    def self.call(param1={})
      new(param1).call
    end

    def call
      raise NotImplementedError, "#{self.class.name}##{__method__}() method has not been implemented!"
    end

    def initialize(parms={})
      @params = parms
    end

    def processor_type
      self.class.processor_type
    end

    def known_test_method
      true
    end

    protected

    # Serializes object to yaml file
    def save_to_yml_file(object, fname)
      o_fn = "#{Rails.root}/controlled/#{fname}.yml"
      File.open(o_fn, "wb") do |file|
        YAML::dump(object, file)
      end
    end

    # Restores object from yaml file
    def restore_from_yml_file(fname)
      i_fn = "#{Rails.root}/controlled/#{fname}.yml"
      YAML::load( IO.read(i_fn) )
    end

  end
end


