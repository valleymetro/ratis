Ratis
==================
A Ruby wrapper for Trapeze Group's ATIS SOAP server.

Goals:

  - Wrap SOAP methods
  - Provide an ActiveRecord like interface to queries
  - Return object representations of SOAP responses
  - Not encapulate any state (other than initial configuration)
  - Try to catch erroneous requests before making a SOAP request
  - Handle SOAP errors when they do occur
  - Handle SOAP method versions changing

Presently based on:

**ATIS - SOAP Interface Specification Version 2.5.1, February 2012**

Known to work with:

 - Ruby 1.8.7
 - Ruby 1.9.3

Gem installation / usage
-------------------
 *Pending*

Development 
-------------------
### Installation
 1. Clone the repo
 1. `bundle install`

### Usage

 1. For development Ratis is hard coded to use a local proxy server on port 8080:

    ssh -i ~/.ssh/authoritylabs.pem -L 8080:localhost:3128 ubuntu@codingsanctum.com

 1. Run the test suite with `rake`
 1. Test it out with `irb -I lib/ -r ratis`

