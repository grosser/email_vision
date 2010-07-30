$LOAD_PATH << 'lib'
require 'rubygems'
require 'email_vision'

describe "EmailVision" do
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
  end

  describe :update do
    it "can update a attribute" do
      value = rand(1111111)
      client.update(changeable_user[:email], :firstname => value)
      sleep 20 # updates need ~ 20 seconds to finish on the server...
      data = client.find(changeable_user[:email])
      data[:firstname].should == value.to_s

      # it does not overwrite other attributes
      data[:lastname].should == changeable_user[:lastname]
    end
  end
end