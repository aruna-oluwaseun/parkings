Timezone::Lookup.config(:google) do |config|
  config.api_key = ENV.fetch("GOOGLE_API_KEY") { '' }
end
