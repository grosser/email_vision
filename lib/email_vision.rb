require 'savon'

class EmailVision
  WSDL = "http://emvapi.emv3.com/apimember/services/MemberService?wsdl"
  NAMESPACE = 'http://api.service.apimember.emailvision.com/'
  SESSION_TIMEOUT = 10*60
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip
  attr_accessor :options
  JOB_STATUS = {
    :finished => 'Job_Done_Or_Does_Not_Exist',
    :error => 'Error'
  }

  def initialize(options)
    self.options = options
  end

  def find(email_or_id)
    result = execute_by_email_or_id(:get_member, email_or_id)
    result = result.first if result.is_a?(Array) # may return multiple users if they have the same email -> return first
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

  def wait_for_job_to_finish(job_id, options={})
    interval = options[:interval] || 5
    times = options[:times] || 20

    times.times do
      current_status = job_status(job_id)
      raise "Job failed" if current_status == JOB_STATUS[:error]
      return true if current_status == JOB_STATUS[:finished]
      sleep interval
    end

    raise "Job not finished in time! #{current_status}"
  end

  def columns
    result = execute(:desc_member_table)
    result = convert_to_hash(result[:fields], :name, :type)
    result.each{|k,v| result[k] = to_ruby_style(v)}
    result
  end

  private

  def connection
    connect! unless connected?
    client
  end

  def client
    @client ||= Savon::Client.new do
      wsdl.document = WSDL
    end
  end

  def connected?
    @token and @token_requested > (Time.now.to_i - SESSION_TIMEOUT)
  end

  def connect!
    @token = request_without_protection(:open_api_connection,
      :login => options[:login],
      :pwd => options[:password],
      :key => options[:key],
      :soap_client => client
    )
    @token_requested = Time.now.to_i
  end

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
    existing_email = attributes.delete(:email_was) || attributes[:email]
    entries = attributes.map do |k,v|
      v = Time.parse(v.to_s) if v.is_a?(Date)
      v = v.strftime('%Y-%m-%d %H:%M:%S') if v.is_a?(Time)
      {:key => k, :value => v}
    end

    execute(method, :member => {:email => existing_email, :dynContent => {:entry => entries}})
  end

  def execute(method, options={})
    request_without_protection(method, options.merge(:token => true))
  rescue Object => e
    if e.respond_to?(:http) and e.http.respond_to?(:body)
      retries ||= -1
      retries += 1
      session_error = (e.http.body =~ /status>(SESSION_RETRIEVING_FAILED|CHECK_SESSION_FAILED)</)
      if session_error
        if retries < 1
          connect!
          retry
        else
          e.message << " -- retried #{retries}"
        end
      end
    end
    raise e
  end

  def request_without_protection(method, options)
    client = options.delete(:soap_client) || connection
    response = client.request(api_namespaced(method)) do |r|
      r.namespaces['xmlns:api'] = NAMESPACE
      options[:token] = @token if options[:token] # token first is generated via connection method
      r.body = options
    end
    response.to_hash["#{method}_response".to_sym][:return]
  end

  def convert_to_hash(entries, key, value)
    entries.inject({}) do |hash, part|
      hash[to_ruby_style(part[key])] = part[value]
      hash
    end
  end

  def api_namespaced(method)
    "api:#{method.to_s.gsub(/_./){|x| x.slice(1,1).upcase }}"
  end
end
