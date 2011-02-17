EmailVision SOAP Api Client

    gem install email_vision

Usage
=====

    emv = EmailVision.new(:password => 'foo', :login => 'bar', :key => 'token')
    emv.find 'me@host.com'
    emv.create_or_update :email => 'me@host.com', :foo => 1

    emv.create :email => 'me@host.com', :foo => 1
    emv.update :email => 'me@host.com', :foo => 1
    emv.update :email_was => 'me@host.com', :email => 'you@host.com'

    emv.columns

    emv.unjoin 'me@host.com'
    emv.rejoin 'me@host.com'

    # create, create_or_update, update, change_email return a job-id
    emv.job_status job_id

Docs
====
 - [EmailVision api](https://docs.google.com/viewer?a=v&pid=explorer&chrome=true&srcid=1FLFs3Jautozs6-ZNcT34oSXJbH6K7szw1wD8cU5i9jpEWjA4p64StquqYa6P&hl=de&authkey=CO383_EP)

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
Hereby placed under public domain, do what you want, just do not hold me accountable...