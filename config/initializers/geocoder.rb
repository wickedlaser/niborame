Geocoder.configure(
  # Geocoding options
  lookup: :google,                 # name of geocoding service (symbol)
  api_key: ENV['GOOGLE_PLACES_API_KEY'],  # API key for geocoding service
  use_https: true,                 # use HTTPS for lookup requests? (if supported)
  timeout: 8,                      # geocoding service timeout (secs)
  units: :km                       # :km for kilometers or :mi for miles
)
