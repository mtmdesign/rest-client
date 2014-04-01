require 'spec_helper'

describe RestClient::Request do
  before(:all) do
    WebMock.disable!
  end

  after(:all) do
    WebMock.enable!
  end

  describe "ssl verification" do
    it "is successful with the correct ca_file" do
      request = RestClient::Request.new(
        :method => :get,
        :url => 'https://www.mozilla.org',
        :ssl_ca_file => File.join(File.dirname(__FILE__), "certs", "digicert.crt")
      )
      expect { request.execute }.to_not raise_error
    end

    it "is successful with the correct ca_path" do
      request = RestClient::Request.new(
        :method => :get,
        :url => 'https://www.mozilla.org',
        :ssl_ca_path => File.join(File.dirname(__FILE__), "capath_digicert")
      )
      expect { request.execute }.to_not raise_error
    end

    # I don' think this feature is useful anymore (under 1.9.3 at the very least).
    #
    # Exceptions in verify_callback are ignored; RestClient has to catch OpenSSL::SSL::SSLError
    # and either re-throw it as is, or throw SSLCertificateNotVerified
    # based on the contents of the message field of the original exception
    #.
    # The client has to handle OpenSSL::SSL::SSLError exceptions anyway,
    # why make them handle both OpenSSL *AND* RestClient exceptions???
    #
    # also see https://github.com/ruby/ruby/blob/trunk/ext/openssl/ossl.c#L237
    it "is unsuccessful with an incorrect ca_file" do
      request = RestClient::Request.new(
        :method => :get,
        :url => 'https://www.mozilla.com',
        :ssl_ca_file => File.join(File.dirname(__FILE__), "certs", "verisign.crt")
      )
      expect { request.execute }.to raise_error(RestClient::SSLCertificateNotVerified)
    end

    it "is unsuccessful with an incorrect ca_path" do
      request = RestClient::Request.new(
        :method => :get,
        :url => 'https://www.mozilla.com',
        :ssl_ca_path => File.join(File.dirname(__FILE__), "capath_verisign")
      )
      expect { request.execute }.to raise_error(RestClient::SSLCertificateNotVerified)
    end

    it "is successful using the default system cert store" do
      request = RestClient::Request.new(
        :method => :get,
        :url => 'https://www.mozilla.org',
        :verify_ssl => true,
      )
      expect {request.execute }.to_not raise_error
    end
  end
end
