# frozen_string_literal: true

require 'spec_helper'
require 'net/http'

describe 'Web application', :webui do
  it 'Check login HTML error flag' do
    # Aquí debes proporcionar la URL de tu aplicación que quieres probar
    host = ENV['TARGET_HOST']
    url = URI.parse("https://#{host}/users/login")

    # Use insecure flag while no SSL has been configured
    http_code = `curl --insecure --head --silent --output /dev/null --write-out '%{http_code}' #{url}`
    expect(http_code).to eq('200')

    body = `curl --insecure --silent #{url}`

    # This banner here means any error occurred
    expect(body).not_to include('<div id="banner">1')
  end
end
