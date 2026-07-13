require 'net/http'
require 'openssl'

# Builds a Net::HTTP client that verifies TLS peer certificates using a fresh
# certificate store. The default OpenSSL store in this environment has CRL
# checking enabled, which fails with "unable to get certificate CRL" for hosts
# that don't publish CRLs. A fresh store with default CA paths verifies the
# certificate chain normally (VERIFY_PEER) without requiring CRLs.
module SecureHttp
  def self.client(uri, open_timeout: 10, read_timeout: 15)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    if http.use_ssl?
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      store = OpenSSL::X509::Store.new
      store.set_default_paths
      http.cert_store = store
    end
    http.open_timeout = open_timeout
    http.read_timeout = read_timeout
    http
  end
end
