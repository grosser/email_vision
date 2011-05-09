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
    # it can be used to wait for the job or fetch its status
    job_id = emv.update :email => 'me@host.com', :foo => 1
    puts "Status is #{emv.job_status job_id}"
    emv.wait_for_job_to_finish job_id # raises when job failed


    # :dateunjoin cannot be set via update, use a separate rejoin / unjoin request
    class User < ActiveRecord::Base
      after_save :update_email_vision

      def update_email_vision
        case receive_newsletter_change
        when [false, true]
          emv.rejoin(email)
          emv.update(...data for emailv vision...)
        when [true, false]
          emv.unjoin(email)
        end
      end
    end

Docs
====
 - [EmailVision api](https://docs.google.com/viewer?a=v&pid=explorer&chrome=true&srcid=1FLFs3Jautozs6-ZNcT34oSXJbH6K7szw1wD8cU5i9jpEWjA4p64StquqYa6P&hl=de&authkey=CO383_EP)

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
Hereby placed under public domain, do what you want, just do not hold me accountable...
