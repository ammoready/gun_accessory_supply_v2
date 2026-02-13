require 'active_support/all'
require 'csv'
require 'cxml'
require 'net/sftp'
require 'tempfile'

require 'gun_accessory_supply/version'
require 'gun_accessory_supply/base'
require 'gun_accessory_supply/catalog'
require 'gun_accessory_supply/category'
require 'gun_accessory_supply/inventory'
require 'gun_accessory_supply/po'
require 'gun_accessory_supply/order'
require 'gun_accessory_supply/tracking'
require 'gun_accessory_supply/user'

module GunAccessorySupply
  class InvalidOrder < StandardError; end
  class NotAuthenticated < StandardError; end
  class FileOrDirectoryNotFound < StandardError; end

  class << self
    attr_accessor :config
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield(config)
  end

  class Configuration
    attr_accessor *%i(
      sftp_host
      sftp_port
      inventory_filename_prefix
      po_filename_prefix
      tracking_filename_prefix
      xml_domain
      xml_secret
      proxy_host
      proxy_port
    )

    def initialize
      @sftp_host ||= "gas.hostedftp.com"
      @sftp_port ||= "22"
    end
  end
end
