module RatisHelpers

  def stub_atis_request
    stub_request :post, 'http://example.com/soap.cgi'
  end

  def an_atis_request
    a_request :post, 'http://example.com/soap.cgi'
  end

  def an_atis_request_for(action, params = {})
    an_atis_request.with do |request|
      request.headers['Soapaction'] == %Q{"TEST_NS##{ action }"}

      params_body   = { action => params.merge( { 'xmlns' => 'TEST_NS' } ) }
      request_body  = Hash.from_xml(request.body)['Envelope']['Body']
      HashDiff.diff(params_body, request_body).should eql []
    end
  end

  def atis_response action, version, action_response_code, action_response_body
    { :body => <<-BODY }
  <?xml version="1.0" encoding="UTF-8"?>
  <SOAP-ENV:Envelope xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/1999/XMLSchema" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <SOAP-ENV:Body>
      <namesp1:#{action}Response xmlns:namesp1="TEST_NS">
        <Responsecode>#{ action_response_code }</Responsecode>
        <Version>#{ version }</Version>
        #{ action_response_body }
        <Copyright>XML schema Copyright (c) 2011 Trapeze Software, Inc., all rights reserved.</Copyright>
        <Soapversion>2.4.4 - 08/31/11</Soapversion>
      </namesp1:#{action}Response>
    </SOAP-ENV:Body>
  </SOAP-ENV:Envelope>
    BODY
  end

  def atis_error_response fault_code, fault_string
    { :body => <<-BODY }
  <?xml version="1.0" encoding="UTF-8"?>
  <SOAP-ENV:Envelope xmlns:namesp1="http://namespaces.soaplite.com/perl" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <SOAP-ENV:Body>
      <SOAP-ENV:Fault>
        <faultcode xsi:type="xsd:string">SOAP-ENV:#{ fault_code }</faultcode>
        <faultstring xsi:type="xsd:string">#{ fault_string }</faultstring>
        <detail>
          <TEST_NS xsi:type="namesp1:TEST_NS">
            <code xsi:type="xsd:int">#{ fault_code }</code>
          </TEST_NS>
        </detail>
      </SOAP-ENV:Fault>
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
      <Calendar>#{ 120.times.map{['y','n'].sample} }</Calendar>
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

end

