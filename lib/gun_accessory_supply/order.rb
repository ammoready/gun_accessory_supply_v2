module GunAccessorySupply
  # To submit an order:
  #
  # * Instantiate a new Order, passing in `:username`
  # * Call {#add_recipient}
  # * Call {#add_item} for each item on the order
  #
  # See each method for a list of required options.
  class Order < Base

    # @option options [String] :username *required*
    def initialize(options = {})
      requires!(options, :username, :password, :po_number, :ship_to_id)

      @po_number  = options[:po_number]
      @ship_to_id = options[:ship_to_id]
      @items      = []
      @options    = options
    end

    # @param header [Hash]
    #   * :dealer_name [String] *required*
    #   * :ffl [String]
    #   * :shipping [Hash] *required*
    #     * :name [String] *required*
    #     * :address [String] *required*
    #     * :city [String] *required*
    #     * :state [String] *required*
    #     * :zip [String] *required*
    #     * :email [String] *required*
    #     * :phone [String] *required*
    #   * :special_instructions [String] optional
    def add_recipient(hash = {})
      requires!(hash, :dealer_name, :shipping)
      requires!(hash[:shipping], :name, :address, :city, :state, :zip, :email)

      @recipient = hash
    end

    # @param item [Hash]
    #   * :identifier [String] *required*
    #   * :description [String]
    #   * :upc [String] *required*
    #   * :qty [Integer] *required*
    #   * :price [String]
    def add_item(item = {})
      requires!(item, :identifier, :upc, :qty)

      @items << item
    end

    def filename
      @filename ||= begin
        timestamp = Time.now.strftime('%Y%m%d%T').gsub(':', '')

        "GUN-ACCESSORY-SUPPLY-#{@po_number}-#{timestamp}.xml"
      end
    end

    def submit!
      write_file("/#{remote_path('in', filename)}", self.to_xml)
    end

    def to_xml
      output = ""
      xml = Builder::XmlMarkup.new(target: output, indent: 2)

      xml.instruct!(:xml)

      xml.cXML(timestamp: Time.now) do
        xml.Header do
          xml.From do
            xml.Credential(domain: GunAccessorySupply.config.xml_domain) do
              xml.Identity GunAccessorySupply.config.xml_domain
              xml.SharedSecret GunAccessorySupply.config.xml_secret
            end
          end
          xml.To do
            xml.Credential(domain: GunAccessorySupply.config.xml_domain) do
              xml.Identity GunAccessorySupply.config.xml_domain
              xml.SharedSecret GunAccessorySupply.config.xml_secret
            end
          end
          xml.Sender do
            xml.Credential(domain: GunAccessorySupply.config.xml_domain) do
              xml.Identity GunAccessorySupply.config.xml_domain
              xml.SharedSecret GunAccessorySupply.config.xml_secret
            end
          end
        end

        xml.Request do
          xml.OrderRequest do
            xml.OrderRequestHeader(orderDate: Time.now, type: 'new', orderID: @po_number) do
              xml.ShipTo do
                xml.Address(addressID: @ship_to_id) do
                  xml.Name @recipient[:dealer_name]
                  xml.Email @recipient[:shipping][:email]
                  xml.PostalAddress do
                    xml.DeliverTo @recipient[:shipping][:name]
                    xml.Street @recipient[:shipping][:address]
                    xml.City @recipient[:shipping][:city]
                    xml.State @recipient[:shipping][:state]
                    xml.PostalCode @recipient[:shipping][:zip]
                    xml.Country "US"
                  end
                end
              end
              xml.BillTo do
                xml.Address do
                  xml.Name @recipient[:dealer_name]
                  xml.Email @recipient[:shipping][:email]
                  xml.PostalAddress do
                    xml.DeliverTo @recipient[:shipping][:name]
                    xml.Street @recipient[:shipping][:address]
                    xml.City @recipient[:shipping][:city]
                    xml.State @recipient[:shipping][:state]
                    xml.PostalCode @recipient[:shipping][:zip]
                    xml.Country "US"
                  end
                end
              end
            end

            @items.each do |item|
              xml.ItemOut(quantity: item[:qty]) do
                xml.ItemID do
                  xml.SupplierPartID item[:identifier]
                end
                xml.ItemDetail do
                  xml.Description item[:upc]
                end
              end
            end
          end
        end
      end

      output
    end

  end
end
