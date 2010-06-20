require 'savon'

class EmailVision
  WSDL = "http://emvapi.emv3.com/apimember/services/MemberService?wsdl"
  attr_accessor :options

  def initialize(options)
    self.options = options
  end

  def connect
    @connection = Savon::Client.new WSDL
    @connection.open_api_connection{|r|
      r.body = {
        :login => options[:login],
        :pwd => options[:password],
        :key => options[:key]
      }
    }
  end
end