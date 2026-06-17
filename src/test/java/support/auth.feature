# =============================================================
# auth.feature
#
# Reusable authentication flow for the Booking API.
# Sends a POST request to obtain a session token
# that is required for protected endpoints such as PUT and DELETE.
#
# @author  Osiris Montiel Campos
# =============================================================

# @ignore prevents this feature from running as a standalone test
@ignore
Feature: Authentication — Obtain a valid session token

  Scenario: Request a session token — POST /auth

    # Send credentials to the auth endpoint to obtain a session token
    Given url bookingBaseUrl
    And path loginEndpoint
    And request
      """
      {
        "username": "admin",
        "password": "password123"
      }
      """
    When method POST

    # Validate that the server responded successfully
    Then status 200
    # Validate that the response contains a non-null token value
    And match response.token != null

    # Extract the token from the response and expose it to the calling feature
    * def token = response.token
    * karate.log('Auth token retrieved successfully:', token)