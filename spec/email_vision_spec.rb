$LOAD_PATH << 'lib'
require 'rubygems'
require 'email_vision'

describe "EmailVision" do
  let(:email){"#{rand(1111111)}.foo@justatest.com"}
  let(:random_value){rand(11111111111).to_s}
  let(:expired_token){'Duy-M5FktALawBJ7dZN94s6hLEgLGKXC_j7cCqlDUMXRGw2shqHYbR9Zud_19EBtFkSCbJ0ZmrZ_d0ieBqgR'}

  # updates need some time to finish on the server...
  def wait_for_job_to_finish
    job_id = yield
    20.times do
      sleep 5
      puts status = client.job_status(job_id)
      return if status == 'Job_Done_Or_Does_Not_Exist'
    end
    raise "Job not finished in time!"
  end

  def reset_email
    email = client.find(changeable_user[:member_id])[:email]
    wait_for_job_to_finish do
      client.update(:email_was => email, :email => changeable_user[:email])
    end
    email = client.find(changeable_user[:member_id])[:email]
    email.should == changeable_user[:email]
  end

  let(:config){YAML.load(File.read('spec/account.yml'))}
  let(:client){EmailVision.new(config)}
  let(:findable_user) do
    data = config[:findable_user]
    data[:datejoin] = DateTime.parse(data[:datejoin].to_s)
    data
  end
  let(:changeable_user){config[:changeable_user]}

  it "has a VERSION" do
    EmailVision::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end

  it "can call more than one method" do
    first = client.find(findable_user[:email])
    first.should == client.find(findable_user[:email])
  end

  it "can reconnect when token is expired" do
    client.instance_variable_set('@token', expired_token)
    client.instance_variable_set('@token_requested', Time.now.to_i - EmailVision::SESSION_TIMEOUT - 10)
    client.find(findable_user[:email])[:email].should == findable_user[:email]
  end

  describe :find do
    it "can find by email" do
      response = client.find(findable_user[:email])
      response.should == findable_user
    end

    it "can find by id" do
      response = client.find(findable_user[:member_id])
      response.should == findable_user
    end

    it "is nil when nothing was found" do
      client.find('foo@bar.baz').should == nil
    end
  end

  describe :update do
    it "can update a attribute" do
      wait_for_job_to_finish do
        client.update(:email => changeable_user[:email], :firstname => random_value)
      end
      puts data = client.find(changeable_user[:email])
      data[:firstname].should == random_value

      # it does not overwrite other attributes
      data[:lastname].should == changeable_user[:lastname]
    end

    it "returns a job id" do
      job_id = client.update(:email => changeable_user[:email], :firstname => random_value)
      client.job_status(job_id).should == 'Insert'
    end

    it "updates the email" do
      begin
        wait_for_job_to_finish do
          client.update(:email_was => changeable_user[:email], :email => email)
        end
        client.find(email)[:email].should == email
      ensure
        reset_email
      end
    end
  end

  describe :create_or_update do
    it "can create a record" do
      wait_for_job_to_finish do
        client.create_or_update(:email => email, :firstname => 'first-name')
      end
      data = client.find(email)
      data[:firstname].should == 'first-name'
    end

    it "can update a record" do
      wait_for_job_to_finish do
        client.create_or_update(:email => changeable_user[:email], :firstname => random_value)
      end
      data = client.find(changeable_user[:email])
      data[:firstname].should == random_value
    end
  end

  describe :create do
    it "can create a record" do
      wait_for_job_to_finish do
        client.create(:email => email, :firstname => 'first-name')
      end
      data = client.find(email)
      data[:firstname].should == 'first-name'
    end
  end

  describe :columns do
    it "can read them" do
      data = client.columns
      data[:dateunjoin].should == :date
    end
  end

  describe :unjoin do
    it "can unjoin a member" do
      wait_for_job_to_finish do
        client.unjoin(changeable_user[:email])
      end
      date = client.find(changeable_user[:email])[:dateunjoin]
      date.is_a?(DateTime).should == true
      Time.parse(date.to_s).should be_close(Time.now, 40)
    end
  end

  describe :rejoin do
    it "can rejoin a member" do
      wait_for_job_to_finish do
        client.rejoin(changeable_user[:email])
      end
      date = client.find(changeable_user[:email])[:datejoin]
      date.is_a?(DateTime).should == true
      Time.parse(date.to_s).should be_close(Time.now, 40)
    end
  end
end