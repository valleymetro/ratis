require 'rspec'
require 'webmock/rspec'
require 'active_support/core_ext'

require 'ratis'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end

def to_soap_request(action, params)
  req = params.to_xml(skip_instruct: true, root: action, skip_types: true, indent: 0)
  req.sub! action, %Q{#{action} xmlns="PX_WEB"}
end

def stub_atis_request
  stub_request :post, 'soap.valleymetro.org/cgi-bin-soap-web-new/soap.cgi'
end

def an_atis_request
  a_request :post, 'soap.valleymetro.org/cgi-bin-soap-web-new/soap.cgi'
end

def atis_response action, version, action_response_code, action_response_body
  { body: <<-BODY }
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/1999/XMLSchema" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <SOAP-ENV:Body>
    <namesp1:#{action}Response xmlns:namesp1="PX_WEB">
      <Responsecode>#{action_response_code}</Responsecode>
      <Version>#{version}</Version>
      #{action_response_body}
      <Copyright>XML schema Copyright (c) 2011 Trapeze Software, Inc., all rights reserved.</Copyright>
      <Soapversion>2.4.4 - 08/31/11</Soapversion>
    </namesp1:#{action}Response>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
  BODY
end

def atis_response_timetable params = {}
  <<-BODY
<Headway>
  <Route>#{params[:route] || '0' }</Route>
  <Direction>#{ params[:direct] || 'N' }</Direction>
  <Servicetype>#{ params[:service_type] || 'W' }</Servicetype>
  <Signage>0 North to Road St.</Signage>
  <Operator>#{ params[:operator] || 'OP' }</Operator>
  <Effective>#{ params[:effective] || '01/15/2012' }</Effective>
  <Timepoints>
    <Stop>
      <Atisstopid>1337</Atisstopid>
      <Stopid>80085</Stopid>
      <Description>ALPHA ST &amp; BETA RD</Description> 
      <Area>Townsville</Area>
    </Stop>
  </Timepoints>
<Times>
  <Trip>
    <Tripid>001-001</Tripid>
    <Block>999</Block>
    <Comment>My trip comment</Comment>
    <Time>12:34 AM</Time>
    <Calendarstartdate>#{ Time.now.strftime '%m/%d/%y' }</Calendarstartdate>
    <Calendar>#{ 120.times.collect{['y','n'].sample} }</Calendar>
    <Commentcode>comment_code_trip</Commentcode>
  </Trip>
</Times>
</Headway>
<Comments>
<Comment>
 <Code>comment_code_request</Code>
 <Text>My request comment</Text>
</Comment>
</Comments>
  BODY
end

