defmodule Astrex.Astro.GeoMag do
  import Math
  alias Astrex.Common
  alias Astrex.Types, as: T
  require Logger

  @moduledoc """
    Calculates the Earth Magnetic field basing on local coordinates and current time
    The calculations model is the WMM (World Magnetic Model).

    More information available here:
        https://www.ngdc.noaa.gov/geomag/WMM/

    The datafile WMM.COF
        https://www.ngdc.noaa.gov/geomag/WMM/data/WMM2020/WMM2020COF.zip
    is valid until 2025 and will be replaced when the next one will be released

    Calculations results have been compared to the results of this calculator's
        https://www.ngdc.noaa.gov/geomag/calculators/magcalc.shtml#declination
    and the prove accurate with an error margin of about 1/100° likely due to floating point roundings

    This code has been directly ported from a python implementation available at
        https://github.com/cmweiss/geomag/blob/master/geomag/geomag/geomag.py
  """

  @coefficients "#{:code.priv_dir(:astrex)}/WMM.COF"

  @doc """
    Requires latitude and longitude expressed in decimal degrees (not deg, min, sec)
    - Latitude: between 0° and 90° -- southern latitudes are negative
    - Longitude: between 0° and +/- 180° -- western logitudes are negative
    - Altitude: in km above sea level - optional parameter, default is 0

  ## Returns
      dec: magnetic declination
      dip: magnetic inclination
      ti: total intensity
      epoch: Epoch of the current datafile

  ## Examples

      iex> Astrex.Astro.GeoMag.mag_declination(%{lat: 45.5, long: 9.15})
      {3.3219734037666426, 61.709940202847136, 47715.72107126719, "2020.0"}
  """
  @spec mag_declination(T.latlong(), number()) :: {float(), float(), float(), binary()}
  def mag_declination(%{lat: lat, long: lon}, h \\ 0) do
    # gv:  grid variation -- valid only for latitudes above/below +/- 55° otherwise -999
    %{dec: dec, dip: dip, ti: ti, gv: _gv, epoch: epoch} = main_algorithm(lat, lon, h)
    {dec, dip, ti, epoch}
  end

  defp process_file(data, c, cd) do
    [line | data] = data

    if line == nil do
      {c, cd}
    else
      keys = [:m, :n, :gnm, :hnm, :dgnm, :dhnm]
      [m, n, gnm, hnm, dgnm, dhnm] = Enum.map(keys, fn key -> line[key] end)

      {c, cd} =
        cond do
          m <= n and m != 0 ->
            c = replace(c, m, n, gnm)
            cd = replace(cd, m, n, dgnm)
            {replace(c, n, m - 1, hnm), replace(cd, n, m - 1, dhnm)}

          m <= n ->
            {replace(c, m, n, gnm), replace(cd, m, n, dgnm)}

          true ->
            {c, cd}
        end

      process_file(data, c, cd)
    end
  end

  defp gc_cycle(k, c, cd, dd2, _n, _m, snorm, _j) when dd2 == 0 do
    {k, c, cd, snorm}
  end

  defp gc_cycle(k, c, cd, dd2, n, m, snorm, j) do
    val = ((n - 1) * (n - 1) - m * m) / ((2.0 * n - 1) * (2.0 * n - 3.0))
    k = replace(k, m, n, val)

    {c, cd, j, snorm} =
      if m > 0 do
        flnmj = (n - m + 1.0) * j / (n + m)
        val = at(snorm, m - 1, n) * Math.sqrt(flnmj)
        snorm = replace(snorm, m, n, val)
        j = 1.0

        val = at(snorm, m, n) * at(c, n, m - 1)
        c = replace(c, n, m - 1, val)

        val = at(snorm, m, n) * at(cd, n, m - 1)
        cd = replace(cd, n, m - 1, val)
        {c, cd, j, snorm}
      else
        {c, cd, j, snorm}
      end

    val = at(snorm, m, n) * at(c, m, n)
    c = replace(c, m, n, val)
    val = at(snorm, m, n) * at(cd, m, n)
    cd = replace(cd, m, n, val)
    gc_cycle(k, c, cd, dd2 - 1, n, m + 1, snorm, j)
  end

  defp gauss_coefficients(_snorm, k, c, cd, n, maxord) when n > maxord do
    {k, c, cd}
  end

  # THIS ONE IS OK
  defp gauss_coefficients(snorm, k, c, cd, n, maxord) do
    val = at(snorm, 0, n - 1) * (2.0 * n - 1) / n
    snorm = replace(snorm, 0, n, val)
    j = 2.0
    m = 0
    dd2 = n - m + 1
    {k, c, cd, snorm} = gc_cycle(k, c, cd, dd2, n, m, snorm, j)
    gauss_coefficients(snorm, k, c, cd, n + 1, maxord)
  end

  # THIS ONE IS OK
  defp init_data do
    %{header: header, data: data} = read_data()
    # TODO epoch can be checked to verify if the WMM.COF file is still valid
    epoch = header[:epoch]
    maxord = 12
    z14 = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    z13 = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    tc = [z13, z13, z13, z13, z13, z13, z13, z13, z13, z13, z13, z13, z13, z13]
    cp = sp = z14
    cp = replace(cp, 0, 1.0)
    pp = z13
    pp = replace(pp, 0, 1.0)
    p = [z14, z14, z14, z14, z14, z14, z14, z14, z14, z14, z14, z14, z14, z14]
    p = replace(p, 0, 0, 1.0)
    dp = [z13, z13, z13, z13, z13, z13, z13, z13, z13, z13, z13, z13, z13, z13]
    c = [z14, z14, z14, z14, z14, z14, z14, z14, z14, z14, z14, z14, z14, z14]
    cd = [z14, z14, z14, z14, z14, z14, z14, z14, z14, z14, z14, z14, z14, z14]

    {c, cd} = process_file(data, c, cd)

    # CONVERT SCHMIDT NORMALIZED GAUSS COEFFICIENTS TO UNNORMALIZED
    snorm = [z13, z13, z13, z13, z13, z13, z13, z13, z13, z13, z13, z13, z13]
    snorm = replace(snorm, 0, 0, 1.0)
    k = [z13, z13, z13, z13, z13, z13, z13, z13, z13, z13, z13, z13, z13]
    k = replace(k, 1, 1, 0.0)
    f_n = [0.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0]
    fm = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0]
    {k, c, cd} = gauss_coefficients(snorm, k, c, cd, 1, maxord)

    {epoch, maxord, tc, sp, cp, f_n, fm, dp, pp, p, k, c, cd}
  end

  defp main_algorithm(lat, lon, h) do
    # TODO check the arguments and if inconsistent exit with {:error, "invalid local data"}
    a = 6378.137
    b = 6356.7523142
    re = 6371.2
    a2 = a * a
    b2 = b * b
    c2 = a2 - b2
    a4 = a2 * a2
    b4 = b2 * b2
    c4 = a4 - b4
    {epoch, maxord, tc, sp, cp, f_n, fm, dp, pp, p, k, c, cd} = init_data()

    time = days_now()
    dt = delta_time(time, epoch)
    alt = h / 3280.8399

    rlat = deg2rad(lat)
    rlon = deg2rad(lon)

    srlon = sin(rlon)
    srlat = sin(rlat)
    crlon = cos(rlon)
    crlat = cos(rlat)

    srlat2 = srlat * srlat
    crlat2 = crlat * crlat
    sp = replace(sp, 1, srlon)
    cp = replace(cp, 1, crlon)

    # CONVERT FROM GEODETIC COORDS. TO SPHERICAL COORDS.
    q = Math.sqrt(a2 - c2 * srlat2)
    q1 = alt * q
    q2 = (q1 + a2) / (q1 + b2) * ((q1 + a2) / (q1 + b2))
    r2 = alt * alt + 2.0 * q1 + (a4 - c4 * srlat2) / (q * q)
    d = Math.sqrt(a2 * crlat2 + b2 * srlat2)

    ct = srlat / Math.sqrt(q2 * crlat2 + srlat2)
    st = Math.sqrt(1.0 - ct * ct)
    r = Math.sqrt(r2)
    ca = (alt + d) / r
    sa = c2 * crlat * srlat / (r * d)

    {sp, cp} = lon_olon_for(sp, cp, 2, maxord)

    aor = re / r
    ar = aor * aor
    br = bt = bp = bpp = 0.0

    {_p, _dp, _tc, bt, bp, br, bpp} =
      outer_cycle(
        p,
        dp,
        tc,
        bt,
        bp,
        br,
        bpp,
        cd,
        cp,
        sp,
        pp,
        fm,
        f_n,
        dt,
        c,
        k,
        ar,
        aor,
        ct,
        st,
        1,
        maxord
      )

    bp =
      if st == 0.0 do
        bpp
      else
        bp / st
      end

    # ROTATE MAGNETIC VECTOR COMPONENTS FROM SPHERICAL TO GEODETIC COORDINATES
    bx = -bt * ca - br * sa
    by = bp
    bz = bt * sa - br * ca

    # COMPUTE DECLINATION (DEC), INCLINATION (DIP) AND TOTAL INTENSITY (TI)
    bh = Math.sqrt(bx * bx + by * by)
    ti = Math.sqrt(bh * bh + bz * bz)
    dec = rad2deg(Math.atan2(by, bx))
    dip = rad2deg(Math.atan2(bz, bh))

    # COMPUTE MAGNETIC GRID VARIATION IF THE CURRENT GEODETIC POSITION IS IN THE ARCTIC OR ANTARCTIC (I.E. LAT > +55 DEGREES OR LAT < -55 DEGREES)
    # OTHERWISE, SET MAGNETIC GRID VARIATION TO -999.0
    gv =
      if abs(lat) >= 55.0 do
        cond do
          lat > 0.0 and lon >= 0.0 -> dec - lon
          lat > 0.0 and lon < 0.0 -> dec + abs(lon)
          lat < 0.0 and lon >= 0.0 -> dec + lon
          lat < 0.0 and lon < 0.0 -> dec - abs(lon)
        end
        |> rectify_range()
      else
        -999.0
      end

    %{dec: dec, dip: dip, ti: ti, gv: gv, epoch: epoch}
  end

  defp outer_cycle(
         p,
         dp,
         tc,
         bt,
         bp,
         br,
         bpp,
         _cd,
         _cp,
         _sp,
         _pp,
         _fm,
         _f_n,
         _dt,
         _c,
         _k,
         _ar,
         _aor,
         _ct,
         _st,
         n,
         maxord
       )
       when n > maxord do
    {p, dp, tc, bt, bp, br, bpp}
  end

  defp outer_cycle(
         p,
         dp,
         tc,
         bt,
         bp,
         br,
         bpp,
         cd,
         cp,
         sp,
         pp,
         fm,
         f_n,
         dt,
         c,
         k,
         ar,
         aor,
         ct,
         st,
         n,
         maxord
       ) do
    ar = ar * aor
    m = 0
    dd4 = n + m + 1

    {p, dp, tc, bt, bp, br, bpp} =
      calculations(
        p,
        dp,
        tc,
        bt,
        bp,
        br,
        bpp,
        cd,
        cp,
        sp,
        pp,
        fm,
        f_n,
        dt,
        c,
        k,
        ar,
        ct,
        st,
        dd4,
        m,
        n
      )

    outer_cycle(
      p,
      dp,
      tc,
      bt,
      bp,
      br,
      bpp,
      cd,
      cp,
      sp,
      pp,
      fm,
      f_n,
      dt,
      c,
      k,
      ar,
      aor,
      ct,
      st,
      n + 1,
      maxord
    )
  end

  defp calculations(
         p,
         dp,
         tc,
         bt,
         bp,
         br,
         bpp,
         _cd,
         _cp,
         _sp,
         _pp,
         _fm,
         _f_n,
         _dt,
         _c,
         _k,
         _ar,
         _ct,
         _st,
         dd4,
         _m,
         _n
       )
       when dd4 <= 0 do
    {p, dp, tc, bt, bp, br, bpp}
  end

  defp calculations(
         p,
         dp,
         tc,
         bt,
         bp,
         br,
         bpp,
         cd,
         cp,
         sp,
         pp,
         fm,
         f_n,
         dt,
         c,
         k,
         ar,
         ct,
         st,
         dd4,
         m,
         n
       ) do
    {p, dp} =
      cond do
        n == m ->
          val = st * at(p, m - 1, n - 1)
          p = replace(p, m, n, val)
          val = st * at(dp, m - 1, n - 1) + ct * at(p, m - 1, n - 1)
          dp = replace(dp, m, n, val)
          {p, dp}

        n == 1 and m == 0 ->
          val = ct * at(p, m, n - 1)
          p = replace(p, m, n, val)
          val = ct * at(dp, m, n - 1) - st * at(p, m, n - 1)
          dp = replace(dp, m, n, val)
          {p, dp}

        n > 1 and n != m ->
          {p, dp} =
            if m > n - 2 do
              p = replace(p, m, n - 2, 0)
              dp = replace(dp, m, n - 2, 0.0)
              {p, dp}
            else
              {p, dp}
            end

          p_val = ct * at(p, m, n - 1) - at(k, m, n) * at(p, m, n - 2)
          p = replace(p, m, n, p_val)

          dp_val = ct * at(dp, m, n - 1) - st * at(p, m, n - 1) - at(k, m, n) * at(dp, m, n - 2)
          dp = replace(dp, m, n, dp_val)
          {p, dp}
      end

    # TIME ADJUST THE GAUSS COEFFICIENTS
    val = at(c, m, n) + dt * at(cd, m, n)
    tc = replace(tc, m, n, val)

    tc =
      if m != 0 do
        val = at(c, n, m - 1) + dt * at(cd, n, m - 1)
        replace(tc, n, m - 1, val)
      else
        tc
      end

    # ACCUMULATE TERMS OF THE SPHERICAL HARMONIC EXPANSIONS
    par = ar * at(p, m, n)

    {temp1, temp2} =
      if m == 0 do
        temp1 = at(tc, m, n) * at(cp, m)
        temp2 = at(tc, m, n) * at(sp, m)
        {temp1, temp2}
      else
        temp1 = at(tc, m, n) * at(cp, m) + at(tc, n, m - 1) * at(sp, m)
        temp2 = at(tc, m, n) * at(sp, m) - at(tc, n, m - 1) * at(cp, m)
        {temp1, temp2}
      end

    bt = bt - ar * temp1 * at(dp, m, n)
    bp = bp + at(fm, m) * temp2 * par
    br = br + at(f_n, n) * temp1 * par

    # SPECIAL CASE:  NORTH/SOUTH GEOGRAPHIC POLES
    {pp, bpp} =
      if st == 0.0 and m == 1 do
        pp =
          if n == 1 do
            replace(pp, n, at(pp, n - 1))
          else
            val = ct * at(pp, n - 1) - at(k, m, n) * at(pp, n - 2)
            replace(pp, n, val)
          end

        parp = ar * at(pp, n)
        bpp = bpp + at(fm, m) * temp2 * parp
        {pp, bpp}
      else
        {pp, bpp}
      end

    calculations(
      p,
      dp,
      tc,
      bt,
      bp,
      br,
      bpp,
      cd,
      cp,
      sp,
      pp,
      fm,
      f_n,
      dt,
      c,
      k,
      ar,
      ct,
      st,
      dd4 - 1,
      m + 1,
      n
    )
  end

  defp lon_olon_for(sp, cp, m, maxord) when m > maxord do
    {sp, cp}
  end

  defp lon_olon_for(sp, cp, m, maxord) do
    sp_val = at(sp, 1) * at(cp, m - 1) + at(cp, 1) * at(sp, m - 1)
    sp = replace(sp, m, sp_val)
    cp_val = at(cp, 1) * at(cp, m - 1) - at(sp, 1) * at(sp, m - 1)
    cp = replace(cp, m, cp_val)
    lon_olon_for(sp, cp, m + 1, maxord)
  end

  defp rectify_range(a) when a >= 180.0 do
    rectify_range(a - 360)
  end

  defp rectify_range(a) when a < -180.0 do
    rectify_range(a + 360)
  end

  defp rectify_range(a) do
    a
  end

  # Extracts an element from a List
  defp at(list, x) do
    Enum.at(list, x)
  end

  # Extracts an element from a 2D List (list of lists)
  defp at(list, x, y) do
    at(list, x) |> at(y)
  end

  defp replace(list, row, newvalue) do
    List.replace_at(list, row, newvalue)
  end

  defp replace(list, row, col, newvalue) do
    r = at(list, row)
    newrow = replace(r, col, newvalue)
    replace(list, row, newrow)
  end

  # returns current year including the fractionary part due to day of the year today
  defp days_now() do
    # now = NaiveDateTime.utc_now |> NaiveDateTime.to_date
    now = Common.ndt_now() |> NaiveDateTime.to_date()
    year = now.year
    {:ok, d1} = Date.from_iso8601("#{year}-01-01")
    days = Date.diff(now, d1)
    now.year + days / 365.0
  end

  defp delta_time(time, epoch) do
    {ep, _} = Float.parse(epoch)
    time - ep
  end

  # reads the data from the WMM.COF file
  # returns a map with
  #         header: map including the header fields
  #         data:   list of maps with the data. one map per row
  defp read_data do
    Logger.info("data file = #{@coefficients}")
    {:ok, data} = File.read(@coefficients)

    [header | data] =
      String.split(data, "\n")
      |> Enum.map(fn line -> process_line(String.split(line)) end)

    %{header: header, data: data}
  end

  defp process_line(fields) when length(fields) == 3 do
    [epoch, model, modeldate] = fields
    %{epoch: epoch, model: model, modeldate: modeldate}
  end

  defp process_line(fields) when length(fields) == 6 do
    [n, m, gnm, hnm, dgnm, dhnm] = fields
    {n, _} = Integer.parse(n)
    {m, _} = Integer.parse(m)
    {gnm, _} = Float.parse(gnm)
    {hnm, _} = Float.parse(hnm)
    {dgnm, _} = Float.parse(dgnm)
    {dhnm, _} = Float.parse(dhnm)
    %{n: n, m: m, gnm: gnm, hnm: hnm, dgnm: dgnm, dhnm: dhnm}
  end

  defp process_line(_fields) do
  end
end
