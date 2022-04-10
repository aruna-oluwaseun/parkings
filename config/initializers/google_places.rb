google_api_key = ENV.fetch('GOOGLE_API_KEY') { '' }
$google_places_client = GooglePlaces::Client.new(google_api_key)
