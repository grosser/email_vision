EmailVision SOAP Api Client

    gem install email_vision

Usage
=====

    emv = EmailVision.new(:password => 'foo', :login => 'bar', :key => 'token')
    emv.find 'me@host.com'
    emv.create :email => 'me@host.com', :foo => 1, :bar => 2
    emv.update :find_by_email => 'old@host.com', :email => 'me@host.com', :foo => 1, :bar => 2
    emv.create_or_update :email => 'me@host.com', :foo => 1, :bar => 2

    See [WSDL](http://emvapi.emv3.com/apimember/services/MemberService?wsdl) for details

Possible actions
================
 - desc_member_table
 - get_list_members_by_obj
 - get_member_by_email
 - get_member_by_id
 - get_member_job_status
 - insert_member
 - insert_member_by_obj
 - insert_or_update_member_by_obj
 - open_partner_connection
 - rejoin_member_by_email
 - rejoin_member_by_id
 - unjoin_member_by_email
 - unjoin_member_by_id
 - unjoin_member_by_obj
 - update_member
 - update_member_by_obj

Author
======
[Michael Grosser](http://pragmatig.wordpress.com)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...