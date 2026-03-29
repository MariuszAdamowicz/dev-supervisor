Feature: Routing

Scenario: fallback to next provider
  Given provider A is first priority
  And provider A returns a quota error
  When a request is sent
  Then provider B is used
  And the response is returned successfully
