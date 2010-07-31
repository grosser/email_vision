$LOAD_PATH << 'lib'
require 'rubygems'
require 'email_vision'

describe "EmailVision" do
  let(:email){"#{rand(1111111)}.foo@justatest.com"}
  let(:random_value){rand(11111111111).to_s}

  # updates need some time to finish on the server...
  def wait_for_updates
    sleep 40
  end

  let(:config){YAML.load(File.read('spec/account.yml'))}
  let(:client){EmailVision.new(config)}
  let(:findable_user) do
    data = config[:findable_user]
    data[:datejoin] = DateTime.parse(data[:datejoin].to_s)
    data
  end
  let(:changeable_user){config[:changeable_user]}

  it "can connect" do
    client.connect
  end

  it "can call more than one method" do
    first = client.find('test@test.de')
    first.should == client.find('test@test.de')
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
      client.update(:email => changeable_user[:email], :firstname => random_value)
      wait_for_updates
      data = client.find(changeable_user[:email])
      data[:firstname].should == random_value

      # it does not overwrite other attributes
      data[:lastname].should == changeable_user[:lastname]
    end

    it "can update the email" do
      client.update(:email_was => changeable_user[:email], :email => email)
      wait_for_updates
      data = client.find(changeable_user[:member_id])
      data[:email].should == email

      # clean up
      client.update(:find_by_email => email, :email => changeable_user[:email])
      wait_for_updates
    end

    it "returns a job id" do
      job_id = client.update(:email => changeable_user[:email], :firstname => random_value)
      client.job_status(job_id).should == 'Insert'
    end
  end

  describe :create_or_update do
    it "can create a record" do
      client.create_or_update(:email => email, :firstname => 'first-name')
      wait_for_updates
      data = client.find(email)
      data[:firstname].should == 'first-name'
    end

    it "can update a record" do
      client.create_or_update(:email => changeable_user[:email], :firstname => random_value)
      wait_for_updates
      data = client.find(changeable_user[:email])
      data[:firstname].should == random_value
    end
  end

  describe :create do
    it "can create a record" do
      client.create(:email => email, :firstname => 'first-name')
      wait_for_updates
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
      client.unjoin(changeable_user[:email])
      wait_for_updates
      date = client.find(changeable_user[:email])[:dateunjoin]
      date.is_a?(DateTime).should == true
      Time.parse(date.to_s).should be_close(Time.now, 40)
    end
  end

  describe :rejoin do
    it "can rejoin a member" do
      client.rejoin(changeable_user[:email])
      wait_for_updates
      date = client.find(changeable_user[:email])[:datejoin]
      date.is_a?(DateTime).should == true
      Time.parse(date.to_s).should be_close(Time.now, 40)
    end
  end
end