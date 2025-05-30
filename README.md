# Astrex

**Astrex is an astronomy library written in Elixir**

provides functions to perfom typical astronomy calculations such as:
- coordinates conversion between equatorial and horizontal coordinates
- calculates the position of solar system objects (Moon and planets)
- calculates the magnetic declination to enable finding the "true north"
- includes a full blown NGC and IC objects database with query functionalities

## History
- version 0.3.4 - first public release
- version 0.4.0 - update WMM.COF to 2025 release - added 200 brightest stars catalogue

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `astrex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:astrex, "~> 0.4.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/astrex>.

