defmodule ServerTest do
  use ExUnit.Case

  test "Genserver Start" do
    Astrex.Server.start_link()
    assert Astrex.Server.get_ll() == %{lat: 51.477928, long: 0.0}
    Astrex.Server.stop
  end

  test "Set coordinates" do
    Astrex.Server.start_link()
    Astrex.Server.set_ll(%{lat: 45.5, long: 9.15})
    assert Astrex.Server.get_ll() == %{lat: 45.5, long: 9.15}
    Astrex.Server.stop
  end
end
