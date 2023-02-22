defmodule TransformsTest do
  use ExUnit.Case

  setup_all do
    Astrex.Server.start_link()
    on_exit(fn -> Astrex.Server.stop end)
    here = %{lat: 45.5, long: 9.15}
    now = Astrex.Common.ndt_now
    [here: here, now: now]
  end

  test "altazimuth to equatorial", %{here: here, now: now} do
    %{ra: ra, dec: dec} = Astrex.Astro.Transforms.az2eq(%{alt: 55.51, az: 178.15}, here, now)
    assert_in_delta(ra, 3.114247, 0.01)
    assert_in_delta(dec, 11.02207, 0.01)
  end

  test "equatorial to altazimuth", %{here: here, now: now} do
    %{alt: alt, az: az} = Astrex.Astro.Transforms.eq2az(%{ra: 3.114, dec: 11.022}, here, now)
    assert_in_delta(alt, 55.50999, 0.01)
    assert_in_delta(az, 178.15000, 0.01)
  end

  test "round trip az2eq2az", %{here: here, now: now} do
    point = %{alt: 72.75, az: 15.36}

    %{alt: falt, az: faz} = Astrex.Astro.Transforms.az2eq(point, here, now) |> Astrex.Astro.Transforms.eq2az(here, now)
    assert_in_delta(point.alt, falt, 0.01)
    assert_in_delta(point.az, faz, 0.01)
  end

  test "round trip eq2az2eq", %{here: here, now: now} do
    point = %{ra: 72.75, dec: 54.36}

    %{ra: fra, dec: fdec} = Astrex.Astro.Transforms.eq2az(point, here, now) |> Astrex.Astro.Transforms.az2eq(here, now)
    assert_in_delta(point.ra, fra, 0.01)
    assert_in_delta(point.dec, fdec, 0.01)
  end

  test "second round trip az2eq2az", %{here: here, now: now} do
    point = %{alt: 45.5, az: 122.15}

    %{alt: falt, az: faz} = Astrex.Astro.Transforms.az2eq(point, here, now) |> Astrex.Astro.Transforms.eq2az(here, now)
    assert_in_delta(point.alt, falt, 0.01)
    assert_in_delta(point.az, faz, 0.01)
  end

  test "second round trip eq2az2eq", %{here: here, now: now} do
    point = %{ra: 4.74, dec: 7.3}

    %{ra: fra, dec: fdec} = Astrex.Astro.Transforms.eq2az(point, here, now) |> Astrex.Astro.Transforms.az2eq(here, now)
    assert_in_delta(point.ra, fra, 0.01)
    assert_in_delta(point.dec, fdec, 0.01)
  end

  test "third round trip az2eq2az", %{here: here, now: now} do
    point = %{alt: -45.5, az: 215.15}

    %{alt: falt, az: faz} = Astrex.Astro.Transforms.az2eq(point, here, now) |> Astrex.Astro.Transforms.eq2az(here, now)
    assert_in_delta(point.alt, falt, 0.01)
    assert_in_delta(point.az, faz, 0.01)
  end

  test "third round trip eq2az2eq", %{here: here, now: now} do
    point = %{ra: 227.74, dec: 87.3}

    %{ra: fra, dec: fdec} = Astrex.Astro.Transforms.eq2az(point, here, now) |> Astrex.Astro.Transforms.az2eq(here, now)
    assert_in_delta(point.ra, fra, 0.01)
    assert_in_delta(point.dec, fdec, 0.01)
  end

  test "fourth round trip az2eq2az", %{here: here, now: now} do
    point = %{alt: 12.5, az: 310.15}

    %{alt: falt, az: faz} = Astrex.Astro.Transforms.az2eq(point, here, now) |> Astrex.Astro.Transforms.eq2az(here, now)
    assert_in_delta(point.alt, falt, 0.01)
    assert_in_delta(point.az, faz, 0.01)
  end

  test "fourth round trip eq2az2eq", %{here: here, now: now} do
    point = %{ra: 354.74, dec: -27.3}

    %{ra: fra, dec: fdec} = Astrex.Astro.Transforms.eq2az(point, here, now) |> Astrex.Astro.Transforms.az2eq(here, now)
    assert_in_delta(point.ra, fra, 0.01)
    assert_in_delta(point.dec, fdec, 0.01)
  end
end
