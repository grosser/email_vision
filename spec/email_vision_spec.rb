$LOAD_PATH << 'lib'
require 'rubygems'
require 'email_vision'

describe "EmailVision" do
  let(:config){YAML.load(File.read('spec/account.yml'))}
  let(:client){EmailVision.new(config)}
  let(:user) do
    data = config[:test_user]
    data[:datejoin] = DateTime.parse(data[:datejoin].to_s)
    data
  end

  it "can connect" do
    client.connect
  end

  it "can getMemberByEmail" do
    response = client.get_member_by_email(:email => user[:email])
    response.should == user
  end

  it "can getMemberById" do
    response = client.get_member_by_id(:id => user[:member_id])
    response.should == user
  end

  it "can call more than one method" do
    first = client.get_member_by_email(:email => 'test@test.de')
    first.should == client.get_member_by_email(:email => 'test@test.de')
  end
end