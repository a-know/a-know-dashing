require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'google_drive'


def setup()
  client = Google::APIClient.new(:application_name => 'Get Value from Google SpreadSheet with Dashing',
      :application_version => '1.0.0')

  file_storage = Google::APIClient::FileStorage.new('credential-oauth2.json')
  if file_storage.authorization.nil?
    flow = Google::APIClient::InstalledAppFlow.new(
      :client_id => ENV['GOOGLE_DRIVE_CLIENT_ID'],
      :client_secret => ENV['GOOGLE_DRIVE_CLIENT_SECRET'],
      :scope => %w(
        https://www.googleapis.com/auth/drive
        https://docs.google.com/feeds/
        https://docs.googleusercontent.com/
        https://spreadsheets.google.com/feeds/
      ),
    )
    client.authorization = flow.authorize(file_storage)
  else
    client.authorization = file_storage.authorization
  end

  return client
end

client = setup()

SCHEDULER.every '10s', :first_in => 0 do |job|
  session = GoogleDrive.login_with_oauth(client.authorization.access_token)
  ws = session.spreadsheet_by_key(ENV['DASHING_TARGET_SPREAD_SHEET_ID']).worksheets[1]

  a = ws[2,2]
  send_event('engineer_offer', { value: a  })
end