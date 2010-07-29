require 'savon'

class EmailVision
  WSDL = "http://emvapi.emv3.com/apimember/services/MemberService?wsdl"
  attr_accessor :options

  def initialize(options)
    self.options = options
  end

  def connect
    @connection = Savon::Client.new WSDL
    response = @connection.open_api_connection{|r|
      r.body = {
        :login => options[:login],
        :pwd => options[:password],
        :key => options[:key]
      }
    }
    @token = response.to_hash[:open_api_connection_response][:return]
    @connection
  end

  def connection
    @connection || connect
  end

  def method_missing(method, options)
    execute(method, options)
  end

  def execute(method, options)
    response = connection.send(method){|r| r.body = options.merge(:token => @token) }
    returned = response.to_hash["#{method}_response".to_sym][:return][:attributes][:entry]
    returned.inject({}) do |hash, part|
      unless part[:value].nil?
        hash[part[:key].downcase.to_sym] = part[:value]
      end
      hash
    end
  end
end