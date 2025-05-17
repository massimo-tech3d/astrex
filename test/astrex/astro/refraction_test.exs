defmodule RefractionTest do
  use ExUnit.Case

  test "magnetic declination" do
    {dec, dip, ti, epoch} = Astrex.Astro.GeoMag.mag_declination(%{lat: 45.5, long: 9.15})
    assert epoch == "2025.0"
    assert_in_delta(dec, 3.2568, 0.001)  # WMM.COF 2025
    assert_in_delta(dip, 61.7123, 0.001)  # WMM.COF 2025
    assert_in_delta(ti, 47700.08, 0.001)  # WMM.COF 2025
  end

  test "true_alt" do
    altaz = %{alt: 45, az: 180}
    %{alt: alt, az: _az} = Astrex.Astro.Refraction.true_alt(altaz)
    assert_in_delta(alt, 44.98342, 0.01)
  end

  test "apparent_alt" do
    altaz = %{alt: 45, az: 180}
    %{alt: alt, az: _az} = Astrex.Astro.Refraction.apparent_alt(altaz)
    assert_in_delta(alt, 45.01689, 0.01)
  end
end
