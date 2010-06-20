$LOAD_PATH << 'lib'
require 'rubygems'
require 'email_vision'

describe "EmailVision" do
  it "can connect" do
    client = EmailVision.new(YAML.load(File.read('spec/account.yml')))
    client.connect
  end
end