# Ratis
A Ruby wrapper for Trapeze Group's ATIS SOAP server.

*Note* This is NOT a public api.  You won't be able to use this gem without being first setup with the Trapeze Group.

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
  1. Include the gem in your Gemfile thus:

        gem 'ratis', '[VERSION]'

  1. Add the following configuration block.

     This must happen before Ratis is `require`d (before `Rails::Initializer.run` in a Rails app).

        require 'ratis/config'
        Ratis.configure do |config|
          config.endpoint = 'http://(YOUR ENDPOINT URL)'
          config.namespace = '(YOUR NAMESPACE)'
          config.proxy = 'http://localhost:8080'
          config.timeout = 5
        end

     If Ratis is `require`d prior to this config being set you will get a `RuntimeError` informing you so.
     If the provided `endpoint` is invalid an `ArgumentError: Invalid URL: bad URI` will be thrown, but only when a request is made.

NOTE ABOUT VERSIONS
-------------------
The versioning strategy for Ratis gem is the major, minor, and build components are set to match the ATIS version you are running. At the time of this edit, ATIS version 2.5.2 is matched with Ratis gem version 2.5.2.x. The last component is the patch version of the gem. This is the number that increases as we add feature from a particular ATIS version.

  1. Add the following configuration block.

     This must happen before Ratis is `require`d (before `Rails::Initializer.run` in a Rails app).

        require 'ratis/config'
        Ratis.configure do |config|
          config.endpoint = 'http://(YOUR ENDPOINT URL)'
          config.namespace = '(YOUR NAMESPACE)'
          config.proxy = 'http://localhost:8080'
          config.timeout = 5
        end

     If Ratis is `require`d prior to this config being set you will get a `RuntimeError` informing you so.
     If the provided `endpoint` is invalid an `ArgumentError: Invalid URL: bad URI` will be thrown, but only when a request is made.

Gem usage
-------------------

### Classes
All the classes should be named to match the ATIS method:

    Itinerary, Landmark, ScheduleNearby, ...

Notable exceptions:

    Routes contains Allroutes method with the thinking that this might be extened for other routes methods, but is probably not necessary and should be renamed

### Queries
By convention most provide either an `all` or `where` class method (following [Active Record's hash conditions syntax](http://guides.rubyonrails.org/active_record_querying.html#hash-conditions)), which will return an array of objects which wrap the response, e.g:

    >> all_landmarks = Landmark.where :type => :all
    >> all_landmarks.count
    => 1510
    >> all_landmarks.first
    => #<Landmark:0x10d263190 @locality="N", @type="AIRPT", @location="4800 E. FALCON DR.", @verbose="FALCON FIELD AIRPORT">

### Errors
The `where` methods will try to sanity check your conditions before making a call to the SOAP server:

    >> Landmark.where({})
    ArgumentError: You must provide a type

    >> Landmark.where :type => :all, :foo => 1
    ArgumentError: Conditions not used by this class: [:foo]

When something goes wrong with the SOAP transaction an `Error` will be raised:

    >> NextBus.where :stop_id => 123456
    #<Error: #10222--Unknown stop>


Development
-------------------

### Installation
 1. Clone the repo
 1. `bundle install`

### Usage

 1. Run the test suite with `rake`
 1. Test it out with `irb -I lib/ -r rubygems -r ratis`
 2. After irb is open with above step, paste in your application's connection config settings. Example:

  Ratis.configure do |config|
    config.endpoint = 'http://(YOUR ENDPOINT URL)'
    config.namespace = '(YOUR NAMESPACE)'
    config.timeout = 5
  end

### Extending

The `Landmark` class is a simple one to look at for reference, and will be referred to below:

#### Testing

You can see the spec for it in `spec/ratis/landmark_spec.rb`, it uses helper methods defined in `spec/spec_helper.rb`:

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

You get the following:


  1. `Request` should be used to make request to the ATIS SOAP server. It ensures the request is built in a way which the ATIS SOAP server expects, provides a version check against responses and returns a `Savon::Response`:

        Request.get 'Getlandmarks', {'Type' => type}

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
