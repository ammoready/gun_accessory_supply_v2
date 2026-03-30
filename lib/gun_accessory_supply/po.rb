module GunAccessorySupply
  class PO < Base

    def initialize(options = {})
      requires!(options, :username, :password)

      @options = options
    end

    def self.file_names(options = {}, po_numbers = [])
      requires!(options, :username, :password)

      new(options).file_names(po_numbers)
    end

    def self.file_data(options = {}, filename)
      requires!(options, :username, :password)

      new(options).file_data(filename)
    end

    def file_names(po_numbers = [])
      filename_regexes = if po_numbers.empty?
        [/#{GunAccessorySupply.config.po_filename_prefix}.*.xml/]
      else
        po_numbers.map do |po_number|
          /#{GunAccessorySupply.config.po_filename_prefix}.*#{po_number}.xml/
        end
      end

      get_full_filenames(filename_regexes, remote_path('out'))
    end

    def file_data(filename)
      CXML::Parser.new.parse(get_file(filename, remote_path('out')).read)
    end

  end
end
