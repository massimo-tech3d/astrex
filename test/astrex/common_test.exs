defmodule Astrex.CommonTest do
  use ExUnit.Case, async: true
  doctest Astrex.Common

  test "radians to hours" do
    # assert Astrex.Common.rad2hours(5) == 19.09859317102744
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
    assert_in_delta(Astrex.Common.hms2hour("13:45:22.5547"), 13.75611111, 0.001)
  end

  # # TODO
  test "degrees:minutes:seconds to degrees" do
    assert_in_delta(Astrex.Common.dms2deg("135:33:54.3269"), 135.565, 0.001)
  end

  # norm_360

  test "normalize 360°" do
    assert_in_delta(Astrex.Common.norm_360(134.5547), 134.5547, 0.001)
    assert_in_delta(Astrex.Common.norm_360(361.5547), 1.5547, 0.001)
    assert_in_delta(Astrex.Common.norm_360(-1.5547), 358.4453, 0.001)
    assert_in_delta(Astrex.Common.norm_360(-361.5547), 358.4453, 0.001)
  end

  # norm_24h

  test "normalize 24h" do
    assert_in_delta(Astrex.Common.norm_24h(13.5547), 13.5547, 0.001)
    assert_in_delta(Astrex.Common.norm_24h(27.5547), 3.5547, 0.001)
    assert_in_delta(Astrex.Common.norm_24h(-1.5547), 22.4453, 0.001)
    assert_in_delta(Astrex.Common.norm_24h(-25.5547), 22.4453, 0.001)
  end

  # norm_2pi

  test "normalize 2PI radians" do
    assert_in_delta(Astrex.Common.norm_2pi(Math.pi()), Math.pi(), 0.001)
    assert_in_delta(Astrex.Common.norm_2pi(2 * Math.pi() + 0.1), 0.1, 0.001)
    assert_in_delta(Astrex.Common.norm_2pi(-Math.pi()), Math.pi(), 0.001)
    assert_in_delta(Astrex.Common.norm_2pi(-Math.pi() + 1), 4.1415, 0.001)
  end

  # gmst in doctests
  # local_sidereal_time
end
