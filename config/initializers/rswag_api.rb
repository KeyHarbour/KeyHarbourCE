Rswag::Api.configure do |c|
  c.openapi_root = KeyHarbourApi::Engine.root.join('swagger').to_s

  c.swagger_filter = lambda do |swagger, env|
    Rails.logger.debug "----" * 50
    Rails.logger.debug swagger["info"]["title"]
    if swagger["info"]["title"] == "API V2"
      swagger['servers'] = [ { 'url' => "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}/api/v2/" } ]
    else
      swagger['servers'] = [ { 'url' => "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}/statefiles/v1/" } ]
    end
  end  
end
