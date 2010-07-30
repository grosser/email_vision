require 'savon'

class EmailVision
  WSDL = "http://emvapi.emv3.com/apimember/services/MemberService?wsdl"
  attr_accessor :options

  def initialize(options)
    self.options = options
  end

  def connect
    response = connection.open_api_connection{|r|
      r.body = {
        :login => options[:login],
        :pwd => options[:password],
        :key => options[:key]
      }
    }
    @token = response.to_hash[:open_api_connection_response][:return]
  end

  def connection
    @connection ||= Savon::Client.new WSDL
  end

  def find(name_or_id)
    if name_or_id.to_s.include?('@')
      execute(:get_member_by_email, :email => name_or_id)
    else
      execute(:get_member_by_id, :id => name_or_id)
    end
  end

  def update(email, attributes)
    execute(:update_member, :email => email, :field => attributes.keys.first, :value => attributes.values.first)
  end

  def method_missing(method, options)
    execute(method, options)
  end

  def execute(method, options)
    connect unless @token
    response = connection.send(method){|r| r.body = options.merge(:token => @token) }
    returned = response.to_hash["#{method}_response".to_sym][:return]
    if returned.is_a?(Hash) and returned[:attributes]
      convert_entries_to_hash(returned[:attributes][:entry])
    else
      returned
    end
  end

  def convert_entries_to_hash(entries)
    entries.inject({}) do |hash, part|
      unless part[:value].nil?
        hash[part[:key].downcase.to_sym] = part[:value]
      end
      hash
    end
  end
end