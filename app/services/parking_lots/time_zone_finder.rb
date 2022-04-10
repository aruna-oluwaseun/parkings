module ParkingLots
  class TimeZoneFinder
    def self.calculate(ltd, lng)
      Timezone.lookup(ltd, lng).name
    rescue Timezone::Error::InvalidZone, Timezone::Error::Lookup
    end
  end
end
