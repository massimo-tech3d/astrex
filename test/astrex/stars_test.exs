defmodule StarsTest do
  use ExUnit.Case  #, async: true
  #doctest Astrex.DeepSky

  # stars mag 0.5 or brigther at greenwich location on 01-01-2023 18:00 (mock time)
  # star               az       alt
  # Capella          46.47°    69.23°
  # Vega             28.25°   297.81°
  # Rigel             7.17°   112.89°
  # Procyon          -4.29°    76.05°
  # Sirius          -13.05°   100.52°
  # Arcturus        -16.58°   337.62°
  # Achernar        -19.25°   172.46°
  # Canopus         -36.01°   131.73°
  # Rigil Kentaurus -71.68°   228.18°

  setup_all do
    Astrex.Server.start_link()
    on_exit(fn -> Astrex.Server.stop end)
    :ok
  end

  test "select stars by mag az alt" do
    assert Astrex.Stars.select_stars(0.5, %{az: 90, d_az: 45, type_az: "IN"}, %{alt: 60, d_alt: 30, type_alt: "IN"}) ==
      [
        %{aka: "Capella", alt: 46.471899486382085, ra: "05:16:41", az: 69.23413116540189, const: "Auriga", dec: "45:59:56", id: "α-Aur", mag: "0.1"}
      ]
    assert Astrex.Stars.select_stars(0.5, %{az: 90, d_az: 45, type_az: "OUT"}, %{alt: 60, d_alt: 30, type_alt: "IN"}) ==
      []
    assert Astrex.Stars.select_stars(0.5, %{az: 90, d_az: 45, type_az: "IN"}, %{alt: 60, d_alt: 30, type_alt: "OUT"}) ==
      [
        %{aka: "Sirius", alt: -13.057787690330622, ra: "06:45:09", az: 100.52410739917546, const: "Canis Major", dec: "-16:42:47", id: "α-CMa", mag: "-1.4"},
        %{aka: "Canopus", alt: -36.018291932764726, ra: "06:23:57", az: 131.73791696086482, const: "Carina", dec: "-52:41:44", id: "α-Car", mag: "-0.6"},
        %{aka: "Rigel", alt: 7.176735179533099, ra: "05:14:32", az: 112.89401627493982, const: "Orion", dec: "-08:12:05", id: "β-Ori", mag: "0.3"},
        %{aka: "Procyon", alt: -4.292759056473423, ra: "07:39:18", az: 76.05487291217511, const: "Canis Minor", dec: "05:13:39", id: "α-CMi", mag: "0.4"}
      ]
    assert Astrex.Stars.select_stars(0.5, %{az: 90, d_az: 45, type_az: "OUT"}, %{alt: 60, d_alt: 30, type_alt: "OUT"}) ==
      [
        %{aka: "Rigil Kentaurus", alt: -71.68742064459886, ra: "14:39:40", az: 228.18421733259387, const: "Centaurus", dec: "-60:50:06", id: "α-Cen", mag: "-0.0"},
        %{aka: "Vega", alt: 28.25618477533259, ra: "18:36:56", az: 297.8147144352378, const: "Lyra", dec: "38:46:58", id: "α-Lyr", mag: "0.0"},
        %{aka: "Arcturus", alt: -16.585528504402962, ra: "14:15:40", az: 337.6290585758656, const: "Bootes", dec: "19:11:14", id: "α-Boo", mag: "0.2"},
        %{aka: "Achernar", alt: -19.256179758399565, ra: "01:37:42", az: 172.46262860557806, const: "Eridanus", dec: "-57:14:11", id: "α-Eri", mag: "0.5"}
      ]
   end

  test "select stars by mag az" do
    assert Astrex.Stars.select_stars(0.5, %{az: 90, d_az: 45, type_az: "IN"}) ==
      [
        %{aka: "Sirius", alt: -13.057787690330622, az: 100.52410739917546, const: "Canis Major", dec: "-16:42:47", id: "α-CMa", mag: "-1.4", ra: "06:45:09"},
        %{aka: "Canopus", alt: -36.018291932764726, az: 131.73791696086482, const: "Carina", dec: "-52:41:44", id: "α-Car", mag: "-0.6", ra: "06:23:57"},
        %{aka: "Capella", alt: 46.471899486382085, az: 69.23413116540189, const: "Auriga", dec: "45:59:56", id: "α-Aur", mag: "0.1", ra: "05:16:41"},
        %{aka: "Rigel", alt: 7.176735179533099, az: 112.89401627493982, const: "Orion", dec: "-08:12:05", id: "β-Ori", mag: "0.3", ra: "05:14:32"},
        %{aka: "Procyon", alt: -4.292759056473423, az: 76.05487291217511, const: "Canis Minor", dec: "05:13:39", id: "α-CMi", mag: "0.4", ra: "07:39:18"}
      ]
    assert Astrex.Stars.select_stars(0.5, %{az: 90, d_az: 45, type_az: "OUT"}) ==
      [
        %{aka: "Rigil Kentaurus", alt: -71.68742064459886, az: 228.18421733259387, const: "Centaurus", dec: "-60:50:06", id: "α-Cen", mag: "-0.0", ra: "14:39:40"},
        %{aka: "Vega", alt: 28.25618477533259, az: 297.8147144352378, const: "Lyra", dec: "38:46:58", id: "α-Lyr", mag: "0.0", ra: "18:36:56"},
        %{aka: "Arcturus", alt: -16.585528504402962, az: 337.6290585758656, const: "Bootes", dec: "19:11:14", id: "α-Boo", mag: "0.2", ra: "14:15:40"},
        %{aka: "Achernar", alt: -19.256179758399565, az: 172.46262860557806, const: "Eridanus", dec: "-57:14:11", id: "α-Eri", mag: "0.5", ra: "01:37:42"}
      ]
  end

  test "select stars by mag alt" do
    assert Astrex.Stars.select_stars(0.5, %{alt: 60, d_alt: 30, type_alt: "IN"}) ==
      [
        %{aka: "Capella", alt: 46.471899486382085, az: 69.23413116540189, const: "Auriga", dec: "45:59:56", id: "α-Aur", mag: "0.1", ra: "05:16:41"}
      ]
    assert Astrex.Stars.select_stars(0.5, %{alt: 60, d_alt: 30, type_alt: "OUT"}) ==
      [
        %{aka: "Sirius", alt: -13.057787690330622, az: 100.52410739917546, const: "Canis Major", dec: "-16:42:47", id: "α-CMa", mag: "-1.4", ra: "06:45:09"},
        %{aka: "Canopus", alt: -36.018291932764726, az: 131.73791696086482, const: "Carina", dec: "-52:41:44", id: "α-Car", mag: "-0.6", ra: "06:23:57"},
        %{aka: "Rigil Kentaurus", alt: -71.68742064459886, az: 228.18421733259387, const: "Centaurus", dec: "-60:50:06", id: "α-Cen", mag: "-0.0", ra: "14:39:40"},
        %{aka: "Vega", alt: 28.25618477533259, az: 297.8147144352378, const: "Lyra", dec: "38:46:58", id: "α-Lyr", mag: "0.0", ra: "18:36:56"},
        %{aka: "Arcturus", alt: -16.585528504402962, az: 337.6290585758656, const: "Bootes", dec: "19:11:14", id: "α-Boo", mag: "0.2", ra: "14:15:40"},
        %{aka: "Rigel", alt: 7.176735179533099, az: 112.89401627493982, const: "Orion", dec: "-08:12:05", id: "β-Ori", mag: "0.3", ra: "05:14:32"},
        %{aka: "Procyon", alt: -4.292759056473423, az: 76.05487291217511, const: "Canis Minor", dec: "05:13:39", id: "α-CMi", mag: "0.4", ra: "07:39:18"},
        %{aka: "Achernar", alt: -19.256179758399565, az: 172.46262860557806, const: "Eridanus", dec: "-57:14:11", id: "α-Eri", mag: "0.5", ra: "01:37:42"}
      ]
  end

  test "select stars by mag sorted by altitude" do
    assert Astrex.Stars.select_stars(0.5) ==
      [
        %{aka: "Capella", alt: 46.471899486382085, az: 69.23413116540189, const: "Auriga", dec: "45:59:56", id: "α-Aur", mag: "0.1", ra: "05:16:41"},
        %{aka: "Vega", alt: 28.25618477533259, az: 297.8147144352378, const: "Lyra", dec: "38:46:58", id: "α-Lyr", mag: "0.0", ra: "18:36:56"},
        %{aka: "Rigel", alt: 7.176735179533099, az: 112.89401627493982, const: "Orion", dec: "-08:12:05", id: "β-Ori", mag: "0.3", ra: "05:14:32"},
        %{aka: "Procyon", alt: -4.292759056473423, az: 76.05487291217511, const: "Canis Minor", dec: "05:13:39", id: "α-CMi", mag: "0.4", ra: "07:39:18"},
        %{aka: "Sirius", alt: -13.057787690330622, az: 100.52410739917546, const: "Canis Major", dec: "-16:42:47", id: "α-CMa", mag: "-1.4", ra: "06:45:09"},
        %{aka: "Arcturus", alt: -16.585528504402962, az: 337.6290585758656, const: "Bootes", dec: "19:11:14", id: "α-Boo", mag: "0.2", ra: "14:15:40"},
        %{aka: "Achernar", alt: -19.256179758399565, az: 172.46262860557806, const: "Eridanus", dec: "-57:14:11", id: "α-Eri", mag: "0.5", ra: "01:37:42"},
        %{aka: "Canopus", alt: -36.018291932764726, az: 131.73791696086482, const: "Carina", dec: "-52:41:44", id: "α-Car", mag: "-0.6", ra: "06:23:57"},
        %{aka: "Rigil Kentaurus", alt: -71.68742064459886, az: 228.18421733259387, const: "Centaurus", dec: "-60:50:06", id: "α-Cen", mag: "-0.0", ra: "14:39:40"},
      ]
  end

  test "select stars by mag" do
    assert Astrex.Stars.select_stars(0.5) ==
      [
        %{aka: "Capella", alt: 46.471899486382085, az: 69.23413116540189, const: "Auriga", dec: "45:59:56", id: "α-Aur", mag: "0.1", ra: "05:16:41"},
        %{aka: "Vega", alt: 28.25618477533259, az: 297.8147144352378, const: "Lyra", dec: "38:46:58", id: "α-Lyr", mag: "0.0", ra: "18:36:56"},
        %{aka: "Rigel", alt: 7.176735179533099, az: 112.89401627493982, const: "Orion", dec: "-08:12:05", id: "β-Ori", mag: "0.3", ra: "05:14:32"},
        %{aka: "Procyon", alt: -4.292759056473423, az: 76.05487291217511, const: "Canis Minor", dec: "05:13:39", id: "α-CMi", mag: "0.4", ra: "07:39:18"},
        %{aka: "Sirius", alt: -13.057787690330622, az: 100.52410739917546, const: "Canis Major", dec: "-16:42:47", id: "α-CMa", mag: "-1.4", ra: "06:45:09"},
        %{aka: "Arcturus", alt: -16.585528504402962, az: 337.6290585758656, const: "Bootes", dec: "19:11:14", id: "α-Boo", mag: "0.2", ra: "14:15:40"},
        %{aka: "Achernar", alt: -19.256179758399565, az: 172.46262860557806, const: "Eridanus", dec: "-57:14:11", id: "α-Eri", mag: "0.5", ra: "01:37:42"},
        %{aka: "Canopus", alt: -36.018291932764726, az: 131.73791696086482, const: "Carina", dec: "-52:41:44", id: "α-Car", mag: "-0.6", ra: "06:23:57"},
        %{aka: "Rigil Kentaurus", alt: -71.68742064459886, az: 228.18421733259387, const: "Centaurus", dec: "-60:50:06", id: "α-Cen", mag: "-0.0", ra: "14:39:40"},
      ]
  end

end
