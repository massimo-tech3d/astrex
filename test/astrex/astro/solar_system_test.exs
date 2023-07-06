defmodule SolarSystemTest do
  use ExUnit.Case, async: true

  setup_all do
    date = ~N[2023-02-22 17:49:15.922068]
    [date: date]
  end

  test "where_is mercury", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:mercury, date)
    assert_in_delta(dec, -17.722839766301167, 0.001)
    assert_in_delta(ra, 21.288300395757794, 0.001)
  end

  test "where_is venus", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:venus, date)
    assert_in_delta(dec, 0.20133797234376521, 0.001)
    assert_in_delta(ra, 0.1872336540065856, 0.001)
  end

  test "where_is mars", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:mars, date)
    assert_in_delta(dec, 25.209300101705068, 0.001)
    assert_in_delta(ra, 4.99724447250351, 0.001)
  end

  test "where_is jupiter", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:jupiter, date)
    assert_in_delta(dec, 2.9724425504740735, 0.001)
    assert_in_delta(ra, 0.6493448330615547, 0.001)
  end

  test "where_is saturn", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:saturn, date)
    assert_in_delta(dec, -13.293190624792858, 0.001)
    assert_in_delta(ra, 22.05290546389081, 0.001)
  end

  test "where_is uranus", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:uranus, date)
    assert_in_delta(dec, 16.03258355833677, 0.001)
    assert_in_delta(ra, 2.8466732019825174, 0.001)
  end

  test "where_is neptune", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:neptune, date)
    assert_in_delta(dec, -3.453481487302545, 0.001)
    assert_in_delta(ra, 23.664245829892298, 0.001)
  end

  test "where_is pluto", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:pluto, date)
    assert_in_delta(dec, -22.64217900497745, 0.001)
    assert_in_delta(ra, 20.11014461959964, 0.001)
  end

  test "where_is moon", %{date: date} do
    %{dec: dec, ra: ra} = Astrex.Astro.SolarSystem.where_is(:moon, date)
    assert_in_delta(dec, 0.7795837757168508, 0.001)
    assert_in_delta(ra, 0.523772873273524, 0.001)
  end
end
