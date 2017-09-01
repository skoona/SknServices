##
# File: <root>/app/strategy/providers/providers_base.rb
#
# Common Base for all Services oriented Classes, without Domains
#

module Providers
  class ProvidersBase
    include Registry::ObjectStorageService

    attr_accessor :registry

    def self.inherited(klass)
      klass.send(:oscs_set_context=, klass.name)
      Rails.logger.debug("#{self.name} inherited By #{klass.name}")
    end

    def initialize(params={})
      params.keys.each do |k|
        instance_variable_set "@#{k.to_s}".to_sym, nil
        instance_variable_set "@#{k.to_s}".to_sym, params[k]
      end
      raise ArgumentError, "Providers: Missing required initialization param!" if @registry.nil?
    end

    # Not required, simply reduces traffic since it is called often
    def current_user
      @current_user ||= registry.current_user
    end

    ##
    # Retrieves Existing ContentProfile for ContentProviders
    def get_prebuilt_profile(pak)
      profile = nil
      profile = get_storage_object(pak)
      Rails.logger.debug("#{self.class.name}.#{__method__}() returns: #{profile.present?}")
      profile
    end

    ##
    # Transaction request enables caller to execute public methods on this object
    #
    # provider.transaction_request(self) do |prov|
    #   prov.provider_method(params)
    #   prov.special_provider_method_that_needs_a_callback(callback, params)
    # end
    #
    def transaction_request(callback, &block)
        block.call(self)
      Rails.logger.debug "transaction_request(Complete) for #{callback.class.name}"
      true
    rescue Exception => e
      Rails.logger.debug "transaction_request(EXCEPTION) #{e.class.name.to_s} #{e.message} #{e.backtrace[0..3].join("\n")}"
      false
    end

    def long_state_name_from_number(key)
      return "" unless (key = key.to_i) > 0
      united_states.detect {|state| state[0] == key }.try(:[],1).try(:titleize)
    end

    def long_state_name_options
      united_states.sort() {|x,y| x[0] <=> y[0]}.map do |state|
        [state[1].titleize, state[0]]
      end
    end

    def get_page_user(uname, context=provider_type())
      Secure::UserProfile.page_user(uname, context)
    end

    protected

    ##
    # generate xml from a regular hash, with/out arrays
    def generate_xml_from_hash(hash, base_type, collection_key)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.send(base_type) { process_simple_array(collection_key, hash, xml) }
      end

      builder.to_xml
    end

    ##
    # generate xml from a hash of hashes or array of hashes
    def generate_xml_from_nested_hashes(data, parent = false, opt = {})
      return if data.to_s.empty?
      return unless data.is_a?(Hash)

      unless parent
        # assume that if the hash has a single key that it should be the root
        root, data = (data.length == 1) ? data.shift : ["root", data]
        builder = Nokogiri::XML::Builder.new(opt) do |xml|
          xml.send(root) {
            generate_xml(data, xml)
          }
        end

        return builder.to_xml
      end

      data.each { |label, value|
        if value.is_a?(Hash)
          attrs = value.fetch('@attributes', {})
          # also passing 'text' as a key makes nokogiri do the same thing
          text = value.fetch('@text', '')
          parent.send(label, attrs, text) {
            value.delete('@attributes')
            value.delete('@text')
            generate_xml(value, parent)
          }

        elsif value.is_a?(Array)
          value.each { |el|
            # lets trick the above into firing so we do not need to rewrite the checks
            el = {label => el}
            generate_xml(el, parent)
          }

        else
          parent.send(label, value)
        end
      }
    end

  private

    # support for #generate_xml_from_hash
    def process_simple_array(label,array,xml)
      array.each do |hash|
        kids,attrs = hash.partition{ |k,v| v.is_a?(Array) }
        xml.send(label,Hash[attrs]) do
          kids.each{ |k,v| process_array(k,v,xml) }
        end
      end
    end

    # Easier to code than delegation, or forwarder; @registry assumed to equal @controller
    def method_missing(method, *args, &block)
      Rails.logger.debug("#{self.class.name}##{__method__}() looking for: #{method}")
      block_given? ? registry.send(method, *args, block) :
          (args.size == 0 ?  registry.send(method) : registry.send(method, *args))
    end

    def united_states
      [
          [54, "ALASKA        ", "AK"],
          [1, "ALABAMA       ", "AL"],
          [3, "ARKANSAS      ", "AR"],
          [2, "ARIZONA       ", "AZ"],
          [4, "CALIFORNIA    ", "CA"],
          [5, "COLORADO      ", "CO"],
          [6, "CONNECTICUT   ", "CT"],
          [8, "WASHINGTON DC ", "DC"],
          [7, "DELAWARE      ", "DE"],
          [9, "FLORIDA       ", "FL"],
          [10, "GEORGIA       ", "GA"],
          [52, "HAWAII        ", "HI"],
          [14, "IOWA          ", "IA"],
          [11, "IDAHO         ", "ID"],
          [12, "ILLINOIS      ", "IL"],
          [13, "INDIANA       ", "IN"],
          [15, "KANSAS        ", "KS"],
          [16, "KENTUCKY      ", "KY"],
          [17, "LOUISIANA     ", "LA"],
          [20, "MASSACHUSETTS ", "MA"],
          [19, "MARYLAND      ", "MD"],
          [18, "MAINE         ", "ME"],
          [21, "MICHIGAN      ", "MI"],
          [22, "MINNESOTA     ", "MN"],
          [24, "MISSOURI      ", "MO"],
          [23, "MISSISSIPPI   ", "MS"],
          [25, "MONTANA       ", "MT"],
          [32, "NORTH CAROLINA", "NC"],
          [33, "NORTH DAKOTA  ", "ND"],
          [26, "NEBRASKA      ", "NE"],
          [28, "NEW HAMPSHIRE ", "NH"],
          [29, "NEW JERSEY    ", "NJ"],
          [30, "NEW MEXICO    ", "NM"],
          [27, "NEVADA        ", "NV"],
          [31, "NEW YORK      ", "NY"],
          [34, "OHIO          ", "OH"],
          [35, "OKLAHOMA      ", "OK"],
          [36, "OREGON        ", "OR"],
          [37, "PENNSYLVANIA  ", "PA"],
          [38, "RHODE ISLAND  ", "RI"],
          [39, "SOUTH CAROLINA", "SC"],
          [40, "SOUTH DAKOTA  ", "SD"],
          [41, "TENNESSEE     ", "TN"],
          [42, "TEXAS         ", "TX"],
          [43, "UTAH          ", "UT"],
          [45, "VIRGINIA      ", "VA"],
          [44, "VERMONT       ", "VT"],
          [46, "WASHINGTON    ", "WA"],
          [48, "WISCONSIN     ", "WI"],
          [47, "WEST VIRGINIA ", "WV"],
          [49, "WYOMING       ", "WY"],
          [58, "PUERTO RICO   ", "PR"],
          [81, "A F AMERICAS  ", "AA"],
          [82, "A F EUROPE    ", "AE"],
          [83, "A F PACIFIC   ", "AP"],
          [84, "AMERICAN SAMOA", "AS"],
          [85, "MICRONESIA    ", "FM"],
          [86, "GUAM          ", "GU"],
          [87, "MARSHALL ISL  ", "MH"],
          [88, "N MARIANA ISL ", "MP"],
          [89, "PALAU         ", "PW"],
          [99, "Not Found     ", "NF"]
      ]
    end

  end
end


