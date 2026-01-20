# frozen_string_literal: true

class OAuthService
  def authenticate_google(id_token)
    # Verify ID token
    payload = verify_google_token(id_token)

    return Result.new(false, nil, ['Invalid Google token']) unless payload

    google_uid = payload['sub']
    email = payload['email']
    full_name = payload['name']
    picture_url = payload['picture']

    # Find or create user
    user = User.find_by(google_uid:) || create_user_from_google(google_uid,
                                                                email,
                                                                full_name,
                                                                picture_url)

    Result.success(user)
  rescue StandardError => e
    Result.failure({ error: e.message })
  end

  private

  def verify_google_token(id_token)
    require 'jwt'
    require 'net/http'
    require 'openssl'
    require 'base64'

    # Decode token header to get kid
    header = JWT.decode(id_token, nil, false)[1]
    kid = header['kid']

    # Get Google's JWKS (JSON Web Key Set)
    uri = URI('https://www.googleapis.com/oauth2/v3/certs')
    response = Net::HTTP.get_response(uri)
    jwks = JSON.parse(response.body)

    # Find the key with matching kid
    key_data = jwks['keys'].find { |key| key['kid'] == kid }
    return nil unless key_data

    # Convert JWK to OpenSSL public key
    public_key = jwk_to_openssl_public_key(key_data)

    # Verify and decode token
    decoded = JWT.decode(id_token, public_key, true, {
      algorithm: 'RS256',
      verify_iat: true,
      verify_expiration: true
    })

    decoded[0] # Return payload
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidIatError => e
    Rails.logger.error("Google token verification failed: #{e}")
    nil
  rescue StandardError => e
    Rails.logger.error("Error verifying Google token: #{e}")
    nil
  end

  def jwk_to_openssl_public_key(jwk)
    require 'openssl'
    require 'base64'

    # Extract modulus and exponent from JWK (base64url encoded)
    n = Base64.urlsafe_decode64(jwk['n'] + '=' * (4 - jwk['n'].length % 4))
    e = Base64.urlsafe_decode64(jwk['e'] + '=' * (4 - jwk['e'].length % 4))

    # Convert to OpenSSL::BN (big-endian)
    modulus = OpenSSL::BN.new(n, 2)
    exponent = OpenSSL::BN.new(e, 2)

    # Create RSA public key using ASN1 sequence
    sequence = OpenSSL::ASN1::Sequence([
      OpenSSL::ASN1::Integer(modulus),
      OpenSSL::ASN1::Integer(exponent)
    ])

    OpenSSL::PKey::RSA.new(sequence.to_der)
  end

  def create_user_from_google(google_uid, email, full_name, _picture_url)
    # Generate a random password since Google OAuth users won't use it
    random_password = SecureRandom.hex(16)

    User.create!(
      google_uid:,
      email:,
      full_name:,
      display_name: full_name.split.first,
      password: random_password,
      password_confirmation: random_password,
      otp_verified: true,
      is_active: true,
      provider: 'google'
    )
  end
end
