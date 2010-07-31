EmailVision SOAP Api Client

    gem install email_vision

Usage
=====

    emv = EmailVision.new(:password => 'foo', :login => 'bar', :key => 'token')
    emv.find 'me@host.com'
    emv.create_or_update :email => 'me@host.com', :foo => 1

    emv.create :email => 'me@host.com', :foo => 1
    emv.update :email_was => 'old@host.com', :email => 'me@host.com', :foo => 1

    emv.columns

    emv.unjoin 'me@host.com'
    emv.rejoin 'me@host.com'

    # create, create_or_update, update return a job-id
    emv.job_status job_id

Author
======
[Michael Grosser](http://pragmatig.wordpress.com)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...