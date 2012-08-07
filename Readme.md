# Ratis
A Ruby wrapper for Trapeze Group's ATIS SOAP server.

Goals:

  - Wrap SOAP methods
  - Provide an ActiveRecord like interface to queries
  - Return object representations of SOAP responses
  - Not encapulate any state (other than initial configuration)
  - Try to catch erroneous queries before making a SOAP request
  - Handle SOAP errors when they do occur
  - Handle SOAP method versions changing

Presently based on:

**ATIS - SOAP Interface Specification Version 2.5.1, February 2012**

Currently Supports Ruby `1.8.7` and `1.9.3`

Gem installation
-------------------
  1. Ensure that an SSH identity with permission for the *authoritylabs* organisation on github is available to Bundler.
  1. Include the gem in your Gemfile thus:

        gem 'ratis', :git => 'git@github.com:authoritylabs/ratis.git'

  1. Add the following (Valley Metro specific) configuration block.

     This must happen before Ratis is `require`d (before `Rails::Initializer.run` in a Rails app).

        require 'ratis/config'
        Ratis.configure do |config|
          config.endpoint = 'http://soap.valleymetro.org/cgi-bin-soap-web-new/soap.cgi'
          config.namespace = 'PX_WEB'
          config.proxy = 'http://localhost:8080'
          config.timeout = 5
        end

     If Ratis is `require`d prior to this config being set you will get a `RuntimeError` informing you so.
     If the provided `endpoint` is invalid an `ArgumentError: Invalid URL: bad URI` will be thrown, but only when a request is made.

Gem usage
-------------------

### Classes
All the classes are prefixed with `Atis`, such as:

    AtisError, AtisItinerary, AtisLandmark, AtisModel, AtisNextBus, AtisRoute,...

All `Atis` classes, with the exception of `AtisModel` and `AtisError` represent data structures returned by SOAP actions.

If you know the SOAP action you want to use, and wish to see if it is implemented in Ratis, you can open a console and ask `AtisModel` to tell you `who_implements_soap_action`:

    > AtisModel.who_implements_soap_action 'Getlandmarks'
    => [AtisLandmark]

### Queries
By convention most provide either an `all` or `where` class method (following [Active Record's hash conditions syntax](http://guides.rubyonrails.org/active_record_querying.html#hash-conditions)), which will return an array of objects which wrap the response, e.g:

    >> all_landmarks = AtisLandmark.where :type => :all
    >> all_landmarks.count
    => 1510
    >> all_landmarks.first
    => #<AtisLandmark:0x10d263190 @locality="N", @type="AIRPT", @location="4800 E. FALCON DR.", @verbose="FALCON FIELD AIRPORT">

### Errors
The `where` methods will try to sanity check your conditions before making a call to the SOAP server:

    >> AtisLandmark.where({})
    ArgumentError: You must provide a type

    >> AtisLandmark.where :type => :all, :foo => 1
    ArgumentError: Conditions not used by this class: [:foo]

When something goes wrong with the SOAP transaction an `AtisError` will be raised:

    >> AtisNextBus.where :stop_id => 123456
    #<AtisError: #10222--Unknown stop>


Development 
-------------------

### Installation
 1. Clone the repo
 1. `bundle install`

### Usage

 1. For development Ratis is hard coded to use a local proxy server on port 8080:

        ssh -i ~/.ssh/authoritylabs.pem -L 8080:localhost:3128 ubuntu@codingsanctum.com

 1. Run the test suite with `rake`
 1. Test it out with `irb -r config/valley_metro.rb -I lib/ -r rubygems -r ratis`

### Extending

The `AtisLandmark` class is a simple one to look at for reference, and will be referred to below:

#### Testing

You can see the spec for it in `spec/ratis/atis_landmark_spec.rb`, it uses helper methods defined in `spec/spec_helper.rb`:

  1. `stub_atis_request` tells `Webmock` to stub a `POST` to the ATIS SOAP server, any request which hasn't been explicitly allowed will trigger an exception.

  1. `atis_response` returns a string of the form returned in the body of a response from the ATIS SOAP server. It takes the SOAP action and version the response appears to be for, and a method specific response code and body.

  Because the method specific response bodies are quite long, it is convenient to wrap them in a heredoc, thus:

         atis_response 'Getlandmarks', '1.4', '0', <<-BODY
           <Landmarks>
           [snip]
           </Landmarks>
         BODY


  1. `an_atis_request` returns a `Webmock` `a_request` object for a `POST` to the ATIS SOAP, which can be used like this:

        an_atis_request.should have_been_made.times 1

  1. `an_atis_request_for` is an `a_request` object for a specific SOAP action with specific parameters passed, which can be used like this:

        an_atis_request_for('Getlandmarks', 'Type' => 'ALL').should have_been_made

#### Implementing

To ease interaction with the ATIS SOAP server the `AtisModel` module is available. Any class which makes requests to the server should:

    require 'ratis/atis_model'
    extend AtisModel

You get the following:

  1. `atis_request` should be used to make request to the ATIS SOAP server. It ensures the request is built in a way which the ATIS SOAP server expects, provides a version check against responses and returns a `Savon::Response`:

        atis_request 'Getlandmarks', {'Type' => type}

  The method and parameter names should be given as described by the ATIS SOAP Interface reference, with the first character uppercase and all others lowercase.

  Now when a request for `Getlandmarks` is made the response's method version will be checked, and an `AtisError` will be thrown if it has not been declared. This ensures that a change on the SOAP server will not result in invalid response parsing by Ratis.

  1. `all_conditions_used?` will raise an `ArgumentError` if the given hash is not empty. 

  Convention in Ratis is to provide a `self.where(conditions)` method (following [Active Record's hash conditions syntax](http://guides.rubyonrails.org/active_record_querying.html#hash-conditions)). As each key in `conditions` is used it can be  `delete`d from `conditions`, then `all_conditions_used? conditions` can be called to ensure nothing unimplemented was passed to `where`.

  It is also wise to raise an `ArgumentError` if an argument which is required isn't present in `conditions`.

  Putting these steps together you get the following pattern:

        type = conditions.delete(:type).to_s.upcase
        raise ArgumentError.new('You must provide a type') if type.blank?
        all_conditions_used? conditions

  Following this pattern will provide a good deal of safety for someone using `where`, and eliminate potentially confusing SOAP errors.

  1. `valid_latitude?` and `valid_longitude?` do range checks.
