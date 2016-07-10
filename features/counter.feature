Feature: Counter API

  Scenario: Get the current counter value
    When I send a GET request to "/counter"
    Then the response code should be 200
    And the response should contain json:
    """
      {
        "value": 42
      }
    """
