defmodule Loin.Cldr do
  @moduledoc """
  A module to call for CLDR-related functions.
  See: https://github.com/elixir-cldr/cldr
  """
  use Cldr,
    locales: ["en"],
    default_locale: "en",
    providers: [Cldr.Number]

end
