defmodule CommonTest do
  use ExUnit.Case, async: true
  doctest Astrex.Common

  test "radians to hours" do
    assert_in_delta(Astrex.Common.rad2hours(5), 19.09859317, 0.001)
  end

  test "hours to radians" do
    assert_in_delta(Astrex.Common.hours2rad(13.556), 3.54895250, 0.001)
  end

  test "hours to degrees" do
    assert_in_delta(Astrex.Common.hours2deg(13.556), 203.33999999, 0.001)
  end

  test "degrees to hours" do
    assert_in_delta(Astrex.Common.deg2hours(178.667), 11.91113333, 0.001)
  end

  test "hours:minutes:seconds to hours" do
    assert_in_delta(Astrex.Common.hms2hours("13:45:22.5547"), 13.75611111, 0.001)
  end

  test "degrees:minutes:seconds to degrees" do
    assert_in_delta(Astrex.Common.dms2deg("135:33:54.3269"), 135.565, 0.001)
  end

  test "hours2hms" do
    assert Astrex.Common.hours2hms(13.35) == "13:20:59"
  end

  test "deg2dms" do
    assert Astrex.Common.deg2dms(55.48) == "55:28:47"
  end

  test "map2rad" do
    %{dec: dec, ra: ra} = Astrex.Common.map2rad(%{ra: 155.45, dec: 57.65})
    assert_in_delta(dec, 1.006182313774731, 0.001)
    assert_in_delta(ra, 2.7131143222251852, 0.001)
  end

  test "map2deg" do
    %{dec: dec, ra: ra} = Astrex.Common.map2deg(%{ra: 1.006182313774731 , dec: 2.7131143222251852})
    assert_in_delta(ra, 57.65, 0.001)
    assert_in_delta(dec, 155.45, 0.001)
  end

  test "normalize 360°" do
    assert_in_delta(Astrex.Common.norm_360(134.5547), 134.5547, 0.001)
    assert_in_delta(Astrex.Common.norm_360(361.5547), 1.5547, 0.001)
    assert_in_delta(Astrex.Common.norm_360(-1.5547), 358.4453, 0.001)
    assert_in_delta(Astrex.Common.norm_360(-361.5547), 358.4453, 0.001)
  end

  test "normalize 24h" do
    assert_in_delta(Astrex.Common.norm_24h(13.5547), 13.5547, 0.001)
    assert_in_delta(Astrex.Common.norm_24h(27.5547), 3.5547, 0.001)
    assert_in_delta(Astrex.Common.norm_24h(-1.5547), 22.4453, 0.001)
    assert_in_delta(Astrex.Common.norm_24h(-25.5547), 22.4453, 0.001)
  end

  test "normalize 2PI radians" do
    assert_in_delta(Astrex.Common.norm_2pi(Math.pi()), Math.pi(), 0.001)
    assert_in_delta(Astrex.Common.norm_2pi(2 * Math.pi() + 0.1), 0.1, 0.001)
    assert_in_delta(Astrex.Common.norm_2pi(-Math.pi()), Math.pi(), 0.001)
    assert_in_delta(Astrex.Common.norm_2pi(-Math.pi() + 1), 4.1415, 0.001)
  end
end
