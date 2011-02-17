task :default => :spec
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--backtrace --color'
end

def account
  YAML.load(File.read('spec/account.yml')) rescue {}
end

def email_vision
  @email_vision ||= begin
    $LOAD_PATH << 'lib'
    require 'email_vision'
    require 'yaml'
    EmailVision.new(account)
  end
end

desc 'possible actions'
task :actions do
  unnecessary_actions = [:open_api_connection, :close_api_connection]
  actions = email_vision.send(:connection).wsdl.soap_actions
  puts (actions - unnecessary_actions).map{|x|" - #{x}"}.sort.join("\n")
end

desc 'test update here, since it takes forever to be processed'
task :test_update do
  user = account[:changeable_user]
  value = rand(1111111)
  email_vision.update(user[:email], :firstname => value)
  start = Time.now
  loop do
    sleep 5
    puts (Time.now - start).to_i
    data = email_vision.find(user[:email])
    break if data[:firstname] == value.to_s
  end
  puts "SUCCESS!!!!!! #{(Time.now - start).to_i}"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name =  'email_vision'
    gem.summary = "Ruby SOAP Api Client for EmailVision / CampaignCommander"
    gem.email = "michael@grosser.it"
    gem.homepage = "http://github.com/grosser/#{gem.name}"
    gem.authors = ["Michael Grosser"]
    gem.add_dependency 'savon'
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler"
end