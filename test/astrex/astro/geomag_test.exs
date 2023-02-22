defmodule GeoMagTest do
  use ExUnit.Case

  test "magnetic declination" do
    {dec, dip, ti, epoch} = Astrex.Astro.GeoMag.mag_declination(%{lat: 45.5, long: 9.15})
    assert_in_delta(dec, 3.3219, 0.001)
    assert_in_delta(dip, 61.7099, 0.001)
    assert_in_delta(ti, 47715.721, 0.001)
    assert epoch == "2020.0"
  end
end
