class ApiRequest < Sequel::Model

  unrestrict_primary_key
  plugin(:timestamps, update_on_create: true)
  plugin(:paranoid)

  many_to_one :api_user_token

  #
  # Verifies if an API request is valid based on its HTTP_AUTHORIZATION header.
  #
  # @param  auth_header = nil [String] HTTP_AUTHORIZATION header to check
  # @param  secret = nil [String] application secret used to hash the signature
  # @param  api_user_token = nil [ApiUserToken] if the request is being made on behalf of a user
  # @return [Boolean] indicating if the request is valid or not
  #
  def self.authorised?(auth_header = nil, secret = nil, api_user_token = nil)

    # check parameters
    return false if auth_header.blank?
    return false if secret.blank?

    # check the structure of the HTTP_AUTHORIZATION header
    return false unless auth_header.start_with?("DREAMWALK-TOKEN-V1")
    auth_hash = extract_hash_from_authorization_header(auth_header)
    return false if auth_hash["nonce"].blank?
    return false if auth_hash["signature"].blank?

    # check the HMAC SHA256 signature hash
    return false unless OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, auth_hash["nonce"]) == auth_hash["signature"]

    # check if the nonce already exists in the database
    return false unless self.where(id: auth_hash["nonce"]).count == 0

    # if an api_user_token was passed, check if it's a valid object before saving
    if api_user_token.present?
      return false if api_user_token.new? or api_user_token.deleted_at.present?
    end

    # try to save the request
    return false unless create(id: auth_hash["nonce"], api_user_token: api_user_token)

    # if we made it this far, return true
    true

  end

  #
  # Private class method used to extract a hash of authorisation parameters from a
  # request's HTTP_AUTHORIZATION header string.
  #
  # @param  authorization_header [String] the HTTP_AUTHORIZATION string
  # @return [Hash] extracted authorisation parameters
  #
  def self.extract_hash_from_authorization_header(authorization_header)
    hash = {}
    authorization_header.gsub(/DREAMWALK-TOKEN-V1/, "").gsub(/, ?/, " ").split(" ").each do |item|
      parts = item.split("=")
      hash[parts[0]] = parts[1].gsub!(/"/,"")
    end
    hash
  end
  private_class_method :extract_hash_from_authorization_header

end
