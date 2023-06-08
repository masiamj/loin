currency_symbols = [
  "DXJ",
  "EWG",
  "EWI",
  "EWJ",
  "EWW",
  "EWT",
  "EWS",
  "EWP",
  "EWQ",
  "EWU",
  "EWC",
  "EWH",
  "TUR",
  "EIDO",
  "ENZL",
  "EPHE",
  "EWA",
  "EWL",
  "EWM",
  "EWO",
  "EWY",
  "EZA",
  "FXI",
  "GXC",
  "MCHI",
  "NORW",
  "EIS",
  "EWZ",
  "PIN",
  "EPOL",
  "EWD",
  "EWK",
  "EWN"
]

{:ok, currencies} = Loin.FMP.get_performance_securities_by_symbols(currency_symbols)

received_symbols = Map.keys(currencies)

symbols = MapSet.difference(MapSet.new(currency_symbols), MapSet.new(received_symbols))
