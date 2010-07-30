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

  def update(attributes)
    execute_by_obj(:update_member_by_obj, attributes)
  end

  def create(attributes)
    execute_by_obj(:insert_member_by_obj, attributes)
  end

  def create_or_update(attributes)
    execute_by_obj(:insert_or_update_member_by_obj, attributes)
  end

  private

  def execute_by_obj(method, attributes)
    attributes = attributes.dup
    find_by_email = attributes.delete(:find_by_email) || attributes.delete(:email)
    entries = attributes.map{|k,v| {:entry => {:key => k, :value => v}}}
    execute(method, :member => {:email => find_by_email, :dynContent => entries})
  end

  def execute(method, options)
    connect unless @token
    response = connection.send(method){|r| r.body = options.merge(:token => @token) }
    returned = response.to_hash["#{method}_response".to_sym][:return]
    if returned.is_a?(Hash) and returned[:attributes]
      convert_response_entries_to_hash(returned[:attributes][:entry])
    else
      returned
    end
  end

  def convert_response_entries_to_hash(entries)
    entries.inject({}) do |hash, part|
      unless part[:value].nil?
        hash[part[:key].downcase.to_sym] = part[:value]
      end
      hash
    end
  end
end