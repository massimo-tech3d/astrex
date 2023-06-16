defmodule Astrex.Astro.Moon do
  # chapter 47 position

  @moduledoc """
    This module exports one function that computes the Moon coordinates
    according to algoritm and QBasic source code from:

    http://www.stargazing.net/kepler/moon.html  QBasic code.
    http://stargazing.net/kepler/moon2.html

    this is faster than Meeus algoritm and reasonably accurate (4 arcminutes 99% of the times 1 arcmin 50% of times)
  """
  import Math
  alias Astrex.Common, as: C
  alias Astrex.Astro.Dates

  @doc """
  receives a NaiveDateTime struct
  returns the Moon's coordinates (RA/DEC) at the specified date/time
  """
  def moon(dt = %NaiveDateTime{}) do
    # vedi se puoi/devi correggere Dates.day_number
    d = Dates.day_number(dt) + 1.5

    # Moon elements
    # Longitude of the Moon's node
    nm = (125.1228 - 0.0529538083 * d) |> deg2rad |> C.norm_2pi()
    im = deg2rad(5.1454)
    # Argument of perihelion for the Moon
    wm = (318.0634 + 0.1643573223 * d) |> deg2rad |> C.norm_2pi()
    # (Earth radius)
    am = 60.2666
    ecm = 0.0549
    # Mean Anomaly of the Moon
    mm = (115.3654 + 13.0649929509 * d) |> deg2rad |> C.norm_2pi()

    # Sun elements
    # Argument of perihelion for the Sun
    ws = (282.9404 + 4.70935e-05 * d) |> deg2rad |> C.norm_2pi()
    # Mean Anomaly of the Sun
    ms = (356.047 + 0.9856002585 * d) |> deg2rad |> C.norm_2pi()

    # position of Moon
    em = mm + ecm * sin(mm) * (1 + ecm * cos(mm))
    xv = am * (cos(em) - ecm)
    yv = am * (sqrt(1 - ecm * ecm) * sin(em))
    vm = atan2(yv, xv)
    rm = sqrt(xv * xv + yv * yv)
    xh = rm * (cos(nm) * cos(vm + wm) - sin(nm) * sin(vm + wm) * cos(im))
    yh = rm * (sin(nm) * cos(vm + wm) + cos(nm) * sin(vm + wm) * cos(im))
    zh = rm * (sin(vm + wm) * sin(im))

    # moons geocentric long and lat
    lon = atan2(yh, xh)
    lat = atan2(zh, sqrt(xh * xh + yh * yh))

    # perturbations
    # first calculate arguments below, which should be in radians
    # Mean Longitude of the Sun  (Ns=0)
    ls = ms + ws
    # Mean longitude of the Moon
    lm = mm + wm + nm
    # Mean elongation of the Moon
    dm = lm - ls
    # Argument of latitude for the Moon
    f = lm - nm

    # then add the following terms to the longitude
    # note amplitudes are in degrees, convert at end
    # (the Evection)
    dlon = -1.274 * sin(mm - 2 * dm)
    # (the Variation)
    dlon = dlon + 0.658 * sin(2 * dm)
    # (the Yearly Equation)
    dlon = dlon - 0.186 * sin(ms)
    dlon = dlon - 0.059 * sin(2 * mm - 2 * dm)
    dlon = dlon - 0.057 * sin(mm - 2 * dm + ms)
    dlon = dlon + 0.053 * sin(mm + 2 * dm)
    dlon = dlon + 0.046 * sin(2 * dm - ms)
    dlon = dlon + 0.041 * sin(mm - ms)
    # (the Parallactic Equation)
    dlon = dlon - 0.035 * sin(dm)
    dlon = dlon - 0.031 * sin(mm + ms)
    dlon = dlon - 0.015 * sin(2 * f - 2 * dm)
    dlon = dlon + 0.011 * sin(mm - 4 * dm)
    lon = deg2rad(dlon) + lon

    # latitude terms
    dlat = -0.173 * sin(f - 2 * dm)
    dlat = dlat - 0.055 * sin(mm - f - 2 * dm)
    dlat = dlat - 0.046 * sin(mm + f - 2 * dm)
    dlat = dlat + 0.033 * sin(f + 2 * dm)
    dlat = dlat + 0.017 * sin(2 * mm + f)
    lat = deg2rad(dlat) + lat

    # distance terms earth radii
    rm = rm - 0.58 * cos(mm - 2 * dm)
    rm = rm - 0.46 * cos(2 * dm)

    # cartesian coordinates of the geocentric lunar position
    xg = rm * cos(lon) * cos(lat)
    yg = rm * sin(lon) * cos(lat)
    zg = rm * sin(lat)

    # rotate to equatorial coords obliquity of ecliptic of date
    ecl = (23.4393 - 3.563e-07 * d) |> deg2rad
    xe = xg
    ye = yg * cos(ecl) - zg * sin(ecl)
    ze = yg * sin(ecl) + zg * cos(ecl)

    # geocentric RA and Dec
    ra = atan2(ye, xe) |> rad2deg
    dec = atan(ze / sqrt(xe * xe + ye * ye)) |> rad2deg
    %{ra: ra, dec: dec}
  end
end
