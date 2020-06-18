module Utils

  def distance_between(from, to, unit=:km)
    Geocoder::Calculations.distance_between(from, to, units: unit)
  end
end
