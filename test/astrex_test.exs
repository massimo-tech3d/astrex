defmodule AstrexTest do
  use ExUnit.Case, async: true
  doctest Astrex

  @az1 %{az: 45.8, alt: 32.5}
  @az2 %{az: 110.24, alt: 68.15}
  @az3 %{az: 234.22, alt: 15.8}
  @az4 %{az: 340.17, alt: 75.35}

  setup_all do
    Astrex.Server.start_link()
    on_exit(fn -> Astrex.Server.stop end)
    :ok
  end

  test "az2eq" do
    %{ra: ra, dec: dec} = Astrex.az2eq(@az1)
    assert_in_delta(ra, 112.91221137985734, 0.001)
    assert_in_delta(dec, 51.86625643372622, 0.001)

    %{ra: ra, dec: dec} = Astrex.az2eq(@az2)
    assert_in_delta(ra, 38.41955387160774, 0.001)
    assert_in_delta(dec, 40.238637973206714, 0.001)

    %{ra: ra, dec: dec} = Astrex.az2eq(@az3)
    assert_in_delta(ra, 319.1899930741205, 0.001)
    assert_in_delta(dec, -7.89529135065895, 0.001)

    %{ra: ra, dec: dec} = Astrex.az2eq(@az4)
    assert_in_delta(ra, 359.5554565971777, 0.001)
    assert_in_delta(dec, 64.83823455494482, 0.001)
  end

  test "eq2az" do
    %{alt: alt, az: az} = Astrex.eq2az(Astrex.az2eq(@az1))
    assert_in_delta(alt, @az1.alt, 0.001)
    assert_in_delta(az, @az1.az, 0.001)

    %{alt: alt, az: az} = Astrex.eq2az(Astrex.az2eq(@az2))
    assert_in_delta(alt, @az2.alt, 0.001)
    assert_in_delta(az, @az2.az, 0.001)

    %{alt: alt, az: az} = Astrex.eq2az(Astrex.az2eq(@az3))
    assert_in_delta(alt, @az3.alt, 0.001)
    assert_in_delta(az, @az3.az, 0.001)

    %{alt: alt, az: az} = Astrex.eq2az(Astrex.az2eq(@az4))
    assert_in_delta(alt, @az4.alt, 0.001)
    assert_in_delta(az, @az4.az, 0.001)
  end

  test "where_is" do
    %{dec: dec, ra: ra} = Astrex.where_is(:mercury)
    assert_in_delta(dec, -20.39432467436096, 0.001)
    assert_in_delta(ra, 19.638348436426217, 0.001)

    %{dec: dec, ra: ra} = Astrex.where_is(:venus)
    assert_in_delta(dec, -21.926200379572297, 0.001)
    assert_in_delta(ra, 20.027448975224342, 0.001)

    %{dec: dec, ra: ra} = Astrex.where_is(:mars)
    assert_in_delta(dec, 24.523655972007912, 0.001)
    assert_in_delta(ra, 4.429819498916916, 0.001)

    %{dec: dec, ra: ra} = Astrex.where_is(:jupiter)
    assert_in_delta(dec, -0.8186309742268472, 0.001)
    assert_in_delta(ra, 0.08962547277392213, 0.001)

    %{dec: dec, ra: ra} = Astrex.where_is(:saturn)
    assert_in_delta(dec, -15.285237885762347, 0.001)
    assert_in_delta(ra, 21.665144627176584, 0.001)

    %{dec: dec, ra: ra} = Astrex.where_is(:uranus)
    assert_in_delta(dec, 15.947591283053544, 0.001)
    assert_in_delta(ra, 2.8327136539869904, 0.001)

    %{dec: dec, ra: ra} = Astrex.where_is(:neptune)
    assert_in_delta(dec, -4.040121291639756, 0.001)
    assert_in_delta(ra, 23.57627820898293, 0.001)

    %{dec: dec, ra: ra} = Astrex.where_is(:pluto)
    assert_in_delta(dec, -22.895228533336187, 0.001)
    assert_in_delta(ra, 19.99296140731663, 0.001)

    %{dec: dec, ra: ra} = Astrex.where_is(:moon)
    assert_in_delta(dec, 15.889732428707166, 0.001)
    assert_in_delta(ra, 2.705974878446635, 0.001)
  end

  test "mag_declination" do
    {a, b, c, d} = Astrex.mag_declination
    assert d == "2025.0"
    assert_in_delta(a, 0.6096713955564532, 0.001)  # WMM.COF 2025
    assert_in_delta(b, 66.49113626555312, 0.001)  # WMM.COF 2025
    assert_in_delta(c, 48990.15325101367, 0.001)  # WMM.COF 2025
  end

  test "sidereal_speeds" do
    {alts, azs} = Astrex.sidereal_speeds(@az1)
    assert_in_delta(alts, 0.0018603785414155318, 0.001)
    assert_in_delta(azs, 0.00210722717010969, 0.001)

    {alts, azs} = Astrex.sidereal_speeds(@az2)
    assert_in_delta(alts, 0.002434757370246251, 0.001)
    assert_in_delta(azs, 0.005498634451246736, 0.001)

    {alts, azs} = Astrex.sidereal_speeds(@az3)
    assert_in_delta(alts, -0.0021052352760464045, 0.001)
    assert_in_delta(azs, 0.0036891077656946575, 0.001)

    {alts, azs} = Astrex.sidereal_speeds(@az4)
    assert_in_delta(alts, -8.803010712750261e-4, 0.001)
    assert_in_delta(azs, -0.006078409578877896, 0.001)
  end

  test "sidereal_speeds2" do
    {alts, azs} = Astrex.sidereal_speeds2(@az1, 1)
    assert_in_delta(alts, 0.0018603785414155318, 0.001)
    assert_in_delta(azs, 0.00210722717010969, 0.001)

    {alts, azs} = Astrex.sidereal_speeds2(@az2, 1)
    assert_in_delta(alts, 0.002434757370246251, 0.001)
    assert_in_delta(azs, 0.005498634451246736, 0.001)

    {alts, azs} = Astrex.sidereal_speeds2(@az3, 1)
    assert_in_delta(alts, -0.0021052352760464045, 0.001)
    assert_in_delta(azs, 0.0036891077656946575, 0.001)

    {alts, azs} = Astrex.sidereal_speeds2(@az4, 1)
    assert_in_delta(alts, -8.803010712750261e-4, 0.001)
    assert_in_delta(azs, -0.006078409578877896, 0.001)
  end
end
