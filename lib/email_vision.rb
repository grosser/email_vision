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

  def find(email_or_id)
    result = execute_by_email_or_id(:get_member, email_or_id)
    return unless result.is_a?(Hash)
    result = convert_to_hash(result[:attributes][:entry], :key, :value)
    result.reject{|k,v| v.nil? }
  end

  def unjoin(email_or_id)
    execute_by_email_or_id(:unjoin_member, email_or_id)
  end

  def rejoin(email_or_id)
    execute_by_email_or_id(:rejoin_member, email_or_id)
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

  # should be one of: Insert, Processing, Processed, Error, Job_Done_Or_Does_Not_Exist
  def job_status(job_id)
    execute(:get_member_job_status, :synchro_id => job_id)[:status]
  end

  def columns
    result = execute(:desc_member_table)
    result = convert_to_hash(result[:fields], :name, :type)
    result.each{|k,v| result[k] = to_ruby_style(v)}
    result
  end

  private

  def execute_by_email_or_id(method, email_or_id)
    if email_or_id.to_s.include?('@')
      execute("#{method}_by_email", :email => email_or_id)
    else
      execute("#{method}_by_id", :id => email_or_id)
    end
  end

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