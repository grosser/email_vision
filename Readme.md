EmailVision SOAP Api Client

    gem install email_vision

Usage
=====

    emv = EmailVision.new(:password => 'foo', :login => 'bar', :key => 'token')
    emv.getMemberByEmail :email => 'me@host.com'
    emv.get_member_by_email :email => 'me@host.com'

    See [WSDL](http://emvapi.emv3.com/apimember/services/MemberService?wsdl) for details

Author
======
[Michael Grosser](http://pragmatig.wordpress.com)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...