module Requests
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body)
    end
  end

  module Methods    
    def authorized(method, action, params: nil, headers: {}, user:)
      user.save
      send(method, action, params: params, headers: headers.merge('Authorization' => "Bearer #{JsonWebToken.encode(user_id: user.id)}"))
    end
  end
end