defmodule Astrex.Astro.SolarSystem do
  # view-source:https://cdpn.io/lulunac27/fullpage/NRoyxE
  # https://aa.quae.nl/en/reken/hemelpositie.html

  @moduledoc """
    This module exports only one function to retrieve the current equatorial
    coordinates of the 9 planets (including Pluto) and of the Moon (via the Astrex.Astro.Moon module)

    The coordinates are returned in Degrees (declination) and Hours (right ascension)

    Algoritm and original javascript source code from
    https://cdpn.io/lulunac27/fullpage/NRoyxE  - planets
  """

  import Math
  alias Astrex.Common, as: C
  alias Astrex.Astro.Dates, as: D
  alias Astrex.Types, as: T

  # machine error constant
  @eps 1.0e-12

  @doc """
  Receives an atom (requested object) and a datetime
  returns the coordinates (RA/DEC) of the requested object

  valid atoms:
    :mercury
    :venus
    :moon
    :mars
    :jupiter
    :saturn
    :uranus
    :neptune
    :pluto
  """
  @spec where_is(T.solar_system(), %NaiveDateTime{}) :: T.equatorial()
  def where_is(:moon, dt = %NaiveDateTime{}) do
    %{ra: ra, dec: dec} = Astrex.Astro.Moon.moon(dt)
    # %{ra: ra |> C.deg2hours |> C.norm_24h |> C.hours2hms, dec: dec |> C.deg2dms}
    %{ra: ra |> C.deg2hours |> C.norm_24h, dec: dec}
  end

  def where_is(planet, dt = %NaiveDateTime{}) do
    day = D.day_number(dt)
    %{a: ap, e: ep, i: ip, oo: oop, w: wp, ll: llp} = mean_elements(planet, day)
    %{a: ae, e: ee, i: _ie, oo: _ooe, w: we, ll: lle} = mean_elements(:earth, day)

    # position of Earth in its orbit
    me = C.norm_2pi(lle - we)
    ve = true_anomaly(me, ee)
    re = ae * (1 - ee * ee) / (1 + ee * cos(ve))

    # heliocentric rectangular coordinates of Earth
    xe = re * cos(ve + we)
    ye = re * sin(ve + we)
    ze = 0.0

    # position of planet in its orbit
    mp = C.norm_2pi(llp - wp)
    vp = true_anomaly(mp, ep)
    rp = ap * (1 - ep * ep) / (1 + ep * cos(vp))

    # heliocentric rectangular coordinates of planet
    xh = rp * (cos(oop) * cos(vp + wp - oop) - sin(oop) * sin(vp + wp - oop) * cos(ip))
    yh = rp * (sin(oop) * cos(vp + wp - oop) + cos(oop) * sin(vp + wp - oop) * cos(ip))
    zh = rp * (sin(vp + wp - oop) * sin(ip))

    # convert to geocentric rectangular coordinates
    xg = xh - xe
    yg = yh - ye
    zg = zh - ze

    # rotate around x axis from ecliptic to equatorial coords
    # value for J2000.0 frame
    ecl = 23.439281 |> deg2rad
    xeq = xg
    yeq = yg * cos(ecl) - zg * sin(ecl)
    zeq = yg * sin(ecl) + zg * cos(ecl)

    # find the RA and DEC from the rectangular equatorial coords
    ra = C.norm_2pi(atan2(yeq, xeq)) |> rad2deg
    dec = atan(zeq / sqrt(xeq * xeq + yeq * yeq)) |> rad2deg
    # distance from earth - not used but could be returned
    _rvec = sqrt(xeq * xeq + yeq * yeq + zeq * zeq)

    %{ra: ra |> C.deg2hours |> C.norm_24h, dec: dec}
    # %{ra: ra |> C.deg2hours |> C.norm_24h |> C.hours2hms, dec: dec |> C.deg2dms}

  end

  # returns the mean orbital elements for planet on day
  defp mean_elements(planet, day) do
    # centuries since J2000
    cy = day / 36525

    case planet do
      :mercury ->
        a = 0.38709893 + 0.00000066 * cy
        e = 0.20563069 + 0.00002527 * cy
        i = (7.00487 - 23.51 * cy / 3600) |> deg2rad
        oo = (48.33167 - 446.30 * cy / 3600) |> deg2rad
        w = (77.45645 + 573.57 * cy / 3600) |> deg2rad
        ll = (252.25084 + 538_101_628.29 * cy / 3600) |> deg2rad |> C.norm_2pi()
        %{a: a, e: e, i: i, oo: oo, w: w, ll: ll}

      :venus ->
        a = 0.72333199 + 0.00000092 * cy
        e = 0.00677323 - 0.00004938 * cy
        i = (3.39471 - 2.86 * cy / 3600) |> deg2rad
        oo = (76.68069 - 996.89 * cy / 3600) |> deg2rad
        w = (131.53298 - 108.80 * cy / 3600) |> deg2rad
        ll = (181.97973 + 210_664_136.06 * cy / 3600) |> deg2rad |> C.norm_2pi()
        %{a: a, e: e, i: i, oo: oo, w: w, ll: ll}

      obj when obj in [:sun, :earth] ->
        a = 1.00000011 - 0.00000005 * cy
        e = 0.01671022 - 0.00003804 * cy
        i = (0.00005 - 46.94 * cy / 3600) |> deg2rad
        oo = (-11.26064 - 18228.25 * cy / 3600) |> deg2rad
        w = (102.94719 + 1198.28 * cy / 3600) |> deg2rad
        ll = (100.46435 + 129_597_740.63 * cy / 3600) |> deg2rad |> C.norm_2pi()
        %{a: a, e: e, i: i, oo: oo, w: w, ll: ll}

      :mars ->
        a = 1.52366231 - 0.00007221 * cy
        e = 0.09341233 + 0.00011902 * cy
        i = (1.85061 - 25.47 * cy / 3600) |> deg2rad
        oo = (49.57854 - 1020.19 * cy / 3600) |> deg2rad
        w = (336.04084 + 1560.78 * cy / 3600) |> deg2rad
        ll = (355.45332 + 68_905_103.78 * cy / 3600) |> deg2rad |> C.norm_2pi()
        %{a: a, e: e, i: i, oo: oo, w: w, ll: ll}

      :jupiter ->
        a = 5.20336301 + 0.00060737 * cy
        e = 0.04839266 - 0.00012880 * cy
        i = (1.30530 - 4.15 * cy / 3600) |> deg2rad
        oo = (100.55615 + 1217.17 * cy / 3600) |> deg2rad
        w = (14.75385 + 839.93 * cy / 3600) |> deg2rad
        ll = (34.40438 + 10_925_078.35 * cy / 3600) |> deg2rad |> C.norm_2pi()
        %{a: a, e: e, i: i, oo: oo, w: w, ll: ll}

      :saturn ->
        a = 9.53707032 - 0.00301530 * cy
        e = 0.05415060 - 0.00036762 * cy
        i = (2.48446 + 6.11 * cy / 3600) |> deg2rad
        oo = (113.71504 - 1591.05 * cy / 3600) |> deg2rad
        w = (92.43194 - 1948.89 * cy / 3600) |> deg2rad
        ll = (49.94432 + 4_401_052.95 * cy / 3600) |> deg2rad |> C.norm_2pi()
        %{a: a, e: e, i: i, oo: oo, w: w, ll: ll}

      :uranus ->
        a = 19.19126393 + 0.00152025 * cy
        e = 0.04716771 - 0.00019150 * cy
        i = (0.76986 - 2.09 * cy / 3600) |> deg2rad
        oo = (74.22988 - 1681.40 * cy / 3600) |> deg2rad
        w = (170.96424 + 1312.56 * cy / 3600) |> deg2rad
        ll = (313.23218 + 1_542_547.79 * cy / 3600) |> deg2rad |> C.norm_2pi()
        %{a: a, e: e, i: i, oo: oo, w: w, ll: ll}

      :neptune ->
        a = 30.06896348 - 0.00125196 * cy
        e = 0.00858587 + 0.00002510 * cy
        i = (1.76917 - 3.64 * cy / 3600) |> deg2rad
        oo = (131.72169 - 151.25 * cy / 3600) |> deg2rad
        w = (44.97135 - 844.43 * cy / 3600) |> deg2rad
        ll = (304.88003 + 786_449.21 * cy / 3600) |> deg2rad |> C.norm_2pi()
        %{a: a, e: e, i: i, oo: oo, w: w, ll: ll}

      :pluto ->
        a = 39.48168677 - 0.00076912 * cy
        e = 0.24880766 + 0.00006465 * cy
        i = (17.14175 + 11.07 * cy / 3600) |> deg2rad
        oo = (110.30347 - 37.33 * cy / 3600) |> deg2rad
        w = (224.06676 - 132.25 * cy / 3600) |> deg2rad
        ll = (238.92881 + 522_747.90 * cy / 3600) |> deg2rad |> C.norm_2pi()
        %{a: a, e: e, i: i, oo: oo, w: w, ll: ll}

      true ->
        {:error, "unknown planet #{planet}"}
    end
  end

  # compute the true anomaly from mean anomaly using iteration
  #   mm - mean anomaly in radians
  #   e  - orbit eccentricity
  defp true_anomaly(mm, e) do
    # initial approximation of eccentric anomaly
    ee = mm + e * sin(mm) * (1.0 + e * cos(mm))
    e1 = ee
    ee = e1 - (e1 - e * sin(e1) - mm) / (1 - e * cos(e1))
    {ee, _e1} = iterate(ee, e1, mm, e)

    # convert eccentric anomaly to true anomaly
    vv = 2 * atan(sqrt((1 + e) / (1 - e)) * tan(0.5 * ee))

    # TODO  |> normalize se non c'è scrivila.
    if vv < 0 do
      vv + 2 * pi()
    else
      vv
    end
  end

  defp iterate(ee, e1, mm, e) when abs(ee - e1) > @eps do
    e1 = ee
    ee = e1 - (e1 - e * sin(e1) - mm) / (1 - e * cos(e1))
    iterate(ee, e1, mm, e)
  end

  defp iterate(ee, e1, _mm, _e) do
    {ee, e1}
  end
end
