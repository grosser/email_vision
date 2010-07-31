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
    result = if name_or_id.to_s.include?('@')
      execute(:get_member_by_email, :email => name_or_id)
    else
      execute(:get_member_by_id, :id => name_or_id)
    end
    return unless result.is_a?(Hash)
    result = convert_to_hash(result[:attributes][:entry], :key, :value)
    result.reject{|k,v| v.nil? }
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

  def columns
    result = execute(:desc_member_table)
    result = convert_to_hash(result[:fields], :name, :type)
    result.each{|k,v| result[k] = to_ruby_style(v)}
    result
  end

  private

  def to_ruby_style(name)
    name.downcase.to_sym
  end

  def execute_by_obj(method, attributes)
    attributes = attributes.dup
    find_by_email = attributes.delete(:email_was) || attributes.delete(:email)
    entries = attributes.map{|k,v| {:entry => {:key => k, :value => v}}}
    execute(method, :member => {:email => find_by_email, :dynContent => entries})
  end

  def execute(method, options={})
    connect unless @token
    response = connection.send(method){|r| r.body = options.merge(:token => @token) }
    response.to_hash["#{method}_response".to_sym][:return]
  end

  def convert_to_hash(entries, key, value)
    entries.inject({}) do |hash, part|
      hash[to_ruby_style(part[key])] = part[value]
      hash
    end
  end
end