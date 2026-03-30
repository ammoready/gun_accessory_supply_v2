module GunAccessorySupply
  class Catalog < Base

    def initialize(options = {})
      requires!(options, :username, :password)
      @options = options
    end

    def self.all(options = {})
      requires!(options, :username, :password)
      new(options).all
    end

    def all
      tempfile = get_file('price_catalog.csv', remote_path('out'))
      items = []

      File.open(tempfile).each_with_index do |row, i|
        row = parse_row(row)

        if i==0
          @headers = row
          next
        end

        category = row[@headers.index('Commerce Category')].try(:strip)

        item = {
          mfg_number:      row[@headers.index('Item ID')].try(:strip),
          upc:             row[@headers.index('UPC')].try(:strip),
          name:            row[@headers.index('Item Description')].try(:strip),
          quantity:        0,
          price:           row[@headers.index('Dealer Cost')].try(:strip),
          msrp:            row[@headers.index('MSRP')].try(:strip),
          map_price:       row[@headers.index('MAP')].try(:strip),
          brand:           row[@headers.index('Brand Name')].try(:strip),
          item_identifier: row[@headers.index('Item ID')].try(:strip),
          category:        category,
          subcategory:     nil,
          weight:          row[@headers.index('Shipping Weight')].try(:strip),
          model:           row[@headers.index('Model')].try(:strip),
          features: {
            caliber:       row[@headers.index('Caliber')].try(:strip),
            image_name:    row[@headers.index('Image URL')].try(:strip),
          }
        }

        items << item
      end

      tempfile.close
      tempfile.unlink

      items
    end

  end
end
