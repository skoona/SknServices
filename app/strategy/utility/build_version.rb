##
# lib/utility/build_version.rb
# Format the current application version according to the current Rail environment
# if production use digit.digit.digit, else use digit.digit.digit.digit
#
# Author: James Scott, Jr. <skoona@gmail.com>
# Date: 3/24/2013

module Utility
  class BuildVersion

    @@pom_version = SknSettings.Packaging.pomVersion.to_s

    # 2.2.x or 2.2.d.d
    def self.build_version(prod_flag=false)
      version = @@pom_version
      version = format_prod if prod_flag || Rails.env.production?

      version
    end

    private

    # 2.2.x
    def self.format_prod
      parts = @@pom_version.split(".")  # results in ["d","d","d","d"]
      rel, rmod = parts[2].to_i, parts[3].to_i
      parts[2] = (rel + 1).to_s if rmod > 4
      parts[0..2].join(".")
    end

  end
end
