defmodule Astrex.GeoMagTest do
  use ExUnit.Case, async: true

  test "magnetic declination" do
    # assert Astrex.Common.rad2hours(5) == 19.09859317102744

    {dec, dip, ti, epoch} = Astrex.GeoMag.mag_decl(45.5, 9.15)
    assert_in_delta(dec, 3.3219, 0.001)
    assert_in_delta(dip, 61.7099, 0.001)
    assert_in_delta(ti, 47715.721, 0.001)
    assert epoch == "2020.0"
  end
end
