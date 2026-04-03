stack: macos-swiftui
architecture: modular-monolith
language: pl
execution-style: iterative-tdd
storage: file-ai
nfr_profile: default-bootstrap-v1

nfr:
  wydajnosc: "p95 czas odpowiedzi interfejsu dla operacji lokalnych <= 300 ms"
  niezawodnosc: "brak crasha aplikacji w 95% sesji roboczych"
  bezpieczenstwo: "brak wysylki danych projektowych poza lokalne srodowisko bez jawnej akcji operatora"
  utrzymywalnosc: "kazdy krytyczny transition ma test lub walidacje automatyczna (build/test/lint)"
  obserwowalnosc: "kazdy krytyczny transition zapisuje ProcessEvent i status QualitySignal"
