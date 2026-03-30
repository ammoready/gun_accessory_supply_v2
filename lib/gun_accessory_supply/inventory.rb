module GunAccessorySupply
  class Inventory < Base

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end

    def self.quantity(options = {})
      requires!(options, :username, :password)
      new(options).quantity
    end

    def all
      tempfile = get_file('catalog_standard.csv', remote_path('out'))
      items = []

      File.open(tempfile).each_with_index do |row, i|
        row = parse_row(row)

        if i==0
          @headers = row
          next
        end

        item = {
          item_identifier: row[@headers.index('Item ID')].try(:strip),
          quantity:        row[@headers.index('Available Qty')].to_i,
          price:           row[@headers.index('Unit Price')].try(:strip),
        }

        items << item
      end

      tempfile.close
      tempfile.unlink

      items
    end

    def quantity
      tempfile = get_file('catalog_standard.csv', remote_path('out'))
      items = []

      File.open(tempfile).each_with_index do |row, i|
        row = parse_row(row)

        if i==0
          @headers = row
          next
        end

        item = {
          item_identifier: row[@headers.index('Item ID')].try(:strip),
          quantity:        row[@headers.index('Available Qty')].to_i,
        }

        items << item
      end

      tempfile.close
      tempfile.unlink

      items
    end

  end
end
