defmodule DatesTest do
  use ExUnit.Case

  test "gmst" do
    date = ~N[1987-04-10 19:21:00]
    gmst = Astrex.Astro.Dates.gmst(date)
    assert_in_delta(gmst, 8.582524, 0.01)
  end

  test "julian_day 1" do
    date = ~N[2023-02-01 16:32:47.565216]
    jd = Astrex.Astro.Dates.julian_day(date)
    assert_in_delta(jd, 2459977.19528, 0.01)
  end

  test "julian_day 2" do
    date = ~N[2022-10-04 10:35:26]
    jd = Astrex.Astro.Dates.julian_day(date)
    assert_in_delta(jd, 2459856.94767, 0.01)
  end

  test "julian_century" do
    date = ~N[2022-10-04 10:35:26]
    jc = Astrex.Astro.Dates.julian_century(date)
    assert_in_delta(jc, 0.22756, 0.01)
  end

  test "day_number" do
    date = ~N[2022-10-04 10:35:26]
    dn = Astrex.Astro.Dates.day_number(date)
    assert_in_delta(dn, 8311.94097, 0.01)
  end
end
