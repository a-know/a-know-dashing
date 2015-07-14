require 'google/api_client'
require 'date'

# Update these to match your own apps credentials
service_account_email = ENV['SERVICE_ACCOUNT_EMAIL'] # Email of service account
profile_id = ENV['PROFILE_ID'] # Analytics profile ID.

# Get the Google API client
client = Google::APIClient.new(
  :application_name => ENV['APPLICATION_NAME'],
  :application_version => '0.01'
)

key = OpenSSL::PKey::RSA.new(ENV['A_KNOW_GOOGLE_API_KEY'])
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience             => 'https://accounts.google.com/o/oauth2/token',
  :scope                => 'https://www.googleapis.com/auth/analytics.readonly',
  :issuer               => service_account_email,
  :signing_key          => key,
)


visitors = []


# Start the scheduler
SCHEDULER.every '1m', :first_in => 0 do

  # Request a token for our service account
  client.authorization.fetch_access_token!

  # Get the analytics API
  analytics = client.discovered_api('analytics','v3')

  # Execute the query
  response = client.execute(:api_method => analytics.data.realtime.get, :parameters => {
    'ids' => "ga:" + profile_id,
    'metrics' => "ga:activeVisitors",
  })

  visitors << { x: Time.now.to_i, y: response.data.rows }

  # Update the dashboard
  send_event('visitor_count_real_time', points: visitors)
end