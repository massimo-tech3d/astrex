defmodule DeepSkyTest do
  use ExUnit.Case  #, async: true
  #doctest Astrex.DeepSky

  setup_all do
    Astrex.Server.start_link()
    on_exit(fn -> Astrex.Server.stop end)
    :ok
  end

  test "find object from default coordinates (greenwich)" do
    assert Astrex.DeepSky.find_object(:messier, 1) ==
             %{
               ar: "05:34:31.97",
               constellation: "Tau",
               decl: "+22:00:52.1",
               id: "NGC1952",
               kind: "SNR",
               magnitude: "",
               messier: "1"
             }

    assert Astrex.DeepSky.find_object(:ngc, 1952) ==
             %{
               ar: "05:34:31.97",
               constellation: "Tau",
               decl: "+22:00:52.1",
               id: "NGC1952",
               kind: "SNR",
               magnitude: "",
               messier: "1"
             }

    assert Astrex.DeepSky.find_object(:ngc, 6554, -25) ==
             %{
               ar: "18:09:23.98",
               constellation: "Sgr",
               decl: "-18:22:43.3",
               id: "NGC6554",
               kind: "OCl",
               magnitude: "",
               messier: ""
             }
  end

  test "select objects" do
    assert Astrex.DeepSky.select_objects(10, :globular_clusters, true, 25) ==
             [
               ["NGC6779", "GCl", "19:16:35.51", "+30:11:04.2", "Lyr", "8.90", "56"],
               ["NGC6838", "GCl", "19:53:46.11", "+18:46:42.2", "Sge", "7.91", "71"],
               ["NGC7078", "GCl", "21:29:58.38", "+12:10:00.6", "Peg", "3.00", "15"]
             ]

    assert Astrex.DeepSky.select_objects(10, :open_clusters, true, 25) ==
             [
               ["NGC0581", "OCl", "01:33:21.81", "+60:39:28.8", "Cas", "7.72", "103"],
               ["NGC1039", "OCl", "02:42:07.40", "+42:44:46.1", "Per", "5.37", "34"],
               ["NGC1912", "OCl", "05:28:42.49", "+35:51:17.7", "Aur", "6.69", "38"],
               ["NGC1960", "OCl", "05:36:17.74", "+34:08:26.7", "Aur", "6.09", "36"],
               ["NGC2099", "OCl", "05:52:18.35", "+32:33:10.8", "Aur", "6.19", "37"],
               ["NGC6913", "OCl", "20:23:57.77", "+38:30:27.6", "Cyg", "7.30", "29"],
               ["NGC7092", "OCl", "21:31:48.32", "+48:26:17.4", "Cyg", "4.66", "39"]
             ]

    assert Astrex.DeepSky.select_objects(10, :galaxies, true, 25) ==
             [
               ["NGC0205", "G", "00:40:22.08", "+41:41:07.1", "And", "8.90", "110"],
               ["NGC0221", "G", "00:42:41.83", "+40:51:55.0", "And", "8.89", "32"],
               ["NGC0224", "G", "00:42:44.35", "+41:16:08.6", "And", "4.29", "31"],
               ["NGC0598", "G", "01:33:50.89", "+30:39:36.8", "Tri", "6.35", "33"],
               ["NGC0628", "G", "01:36:41.75", "+15:47:01.2", "Psc", "9.71", "74"],
               ["NGC1068", "G", "02:42:40.71", "-00:00:47.8", "Cet", "9.74", "77"],
               ["NGC3031", "G", "09:55:33.17", "+69:03:55.1", "UMa", "7.79", "81"],
               ["NGC3034", "G", "09:55:52.73", "+69:40:45.8", "UMa", "8.94", "82"]
             ]
  end
end
