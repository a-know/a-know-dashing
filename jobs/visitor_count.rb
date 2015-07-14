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


# Start the scheduler
SCHEDULER.every '1m', :first_in => 0 do

  # Request a token for our service account
  client.authorization.fetch_access_token!

  # Get the analytics API
  analytics = client.discovered_api('analytics','v3')

  # Start and end dates
  ENV['TZ'] = 'Asia/Tokyo'
  startDate = Time.now.strftime("%Y-%m-%d")
  endDate = startDate

  # Execute the query
  visitCount = client.execute(:api_method => analytics.data.ga.get, :parameters => {
    'ids' => "ga:" + profile_id,
    'start-date' => startDate,
    'end-date' => endDate,
    # 'dimensions' => "ga:month",
    'metrics' => "ga:pageviews",
    # 'sort' => "ga:month"
  })

  # Update the dashboard
  # Note the trailing to_i - See: https://github.com/Shopify/dashing/issues/33
  send_event('visitor_count',   { current: visitCount.data.rows[0][0].to_i })
end