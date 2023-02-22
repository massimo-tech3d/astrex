defmodule SolarSystemTest do
  use ExUnit.Case, async: true

  setup_all do
    date = ~N[2023-02-22 17:49:15.922068]
    [date: date]
  end

  test "where_is mercury", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:mercury, date)
    assert_in_delta(dec, -17.722839766301167, 0.001)
    assert_in_delta(ra, 319.3245059363669, 0.001)
  end

  test "where_is venus", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:venus, date)
    assert_in_delta(dec, 0.20133797234376521, 0.001)
    assert_in_delta(ra, 2.8085048100987837, 0.001)
  end

  test "where_is mars", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:mars, date)
    assert_in_delta(dec, 25.209300101705068, 0.001)
    assert_in_delta(ra, 74.95866708755266, 0.001)
  end

  test "where_is jupiter", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:jupiter, date)
    assert_in_delta(dec, 2.9724425504740735, 0.001)
    assert_in_delta(ra, 9.74017249592332, 0.001)
  end

  test "where_is saturn", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:saturn, date)
    assert_in_delta(dec, -13.293190624792858, 0.001)
    assert_in_delta(ra, 330.79358195836215, 0.001)
  end

  test "where_is uranus", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:uranus, date)
    assert_in_delta(dec, 16.03258355833677, 0.001)
    assert_in_delta(ra, 42.70009802973776, 0.001)
  end

  test "where_is neptune", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:neptune, date)
    assert_in_delta(dec, -3.453481487302545, 0.001)
    assert_in_delta(ra, 354.96368744838446, 0.001)
  end

  test "where_is pluto", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:pluto, date)
    assert_in_delta(dec, -22.64217900497745, 0.001)
    assert_in_delta(ra, 301.65216929399463, 0.001)
  end

  test "where_is moon", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:moon, date)
    assert_in_delta(dec, 0.7795837757168508, 0.001)
    assert_in_delta(ra, 0.523772873273524, 0.001)
  end
end
