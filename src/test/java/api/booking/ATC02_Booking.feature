# =============================================================
# ATC02_Booking.feature
#
# Validates the full CRUD lifecycle of the Booking API.
# Covers creating, updating, and deleting a reservation,
#
# @author  Osiris Montiel Campos
# @epic    API Automation
# @feature Booking
# =============================================================
Feature: API Booking — Full CRUD lifecycle for reservations

  # Runs before each scenario to initialize test data
  # and attempt to retrieve any booking ID stored by a previous scenario
  Background:
    # Load test data values from the external JSON file
    * def td = read('classpath:support/testdata-booking.json').ATC02_Booking
    # Retrieve shared booking ID if it was stored by a previous scenario
    # Returns null if no value has been stored yet
    * def bookingId = karate.get('sharedBookingId', null)


  # =============================================================
  # TC01 — Create Booking
  # Sends a POST request to create a new reservation.
  # Validates that the response returns status 200
  # and that the booking data matches the request payload.
  # =============================================================
  @TC01 @CRITICAL @createBooking
  Scenario: TC01 - Successfully create a new reservation record — POST /booking

    # Build and send the POST request with the full booking payload
    Given url bookingBaseUrl
    And path bookingEndpoint
    And request
      """
      {
        "firstname":      "#(td.FirstName)",
        "lastname":       "#(td.LastName)",
        "totalprice":     #(td.TotalPrice),
        "depositpaid":    #(td.DepositPaid),
        "bookingdates": {
          "checkin":  "#(td.Checkin)",
          "checkout": "#(td.Checkout)"
        },
        "additionalneeds": "#(td.AdditionalNeeds)"
      }
      """
    When method POST

    # Validate the response status code
    Then status 200
    # Validate that the server assigned a booking ID to the new record
    And match response.bookingid != null
    # Validate that the returned data matches what was sent in the request
    And match response.booking.firstname == td.FirstName
    And match response.booking.lastname  == td.LastName

    # Store the generated booking ID so subsequent scenarios can use it
    * def createdId = response.bookingid
    * karate.set('sharedBookingId', createdId)
    * karate.log('Booking created successfully with ID:', createdId)


  # =============================================================
  # TC02 — Update Booking
  # Sends a PUT request to update the checkin and checkout dates
  # of an existing reservation using an authenticated session token.
  # Validates that the response returns status 200
  # and that the dates reflect the updated values.
  # =============================================================
  @TC02 @CRITICAL @updateBooking
  Scenario: TC02 - Should update reservation dates using an active auth token — PUT /booking/{id}

    # Request a session token by calling the reusable auth feature
    * def authResult = call read('classpath:support/auth.feature')
    * def token = authResult.token
    * karate.log('Auth token retrieved:', token)

    # Search for the booking by firstname to obtain its ID
    Given url bookingBaseUrl
    And path bookingEndpoint
    And param firstname = td.FirstName
    When method GET
    Then status 200
    # Extract the ID from the first result in the returned array
    * def bookingId = response[0].bookingid
    * karate.log('Booking ID to update:', bookingId)

    # Send the PUT request with updated dates
    # The token is passed in the Cookie header as required by the API
    Given url bookingBaseUrl
    And path bookingEndpoint + '/' + bookingId
    And header Cookie = 'token=' + token
    And request
      """
      {
        "firstname":   "#(td.FirstName)",
        "lastname":    "#(td.LastName)",
        "totalprice":  #(td.TotalPrice),
        "depositpaid": #(td.DepositPaid),
        "bookingdates": {
          "checkin":  "#(td.NewCheckin)",
          "checkout": "#(td.NewCheckout)"
        },
        "additionalneeds": "#(td.AdditionalNeeds)"
      }
      """
    When method PUT

    # Validate the response status code
    Then status 200
    # Validate that the returned dates match the updated values sent in the request
    And match response.bookingdates.checkin  == td.NewCheckin
    And match response.bookingdates.checkout == td.NewCheckout
    * karate.log('Booking updated successfully')


  # =============================================================
  # TC03 — Delete Booking
  # Sends a DELETE request to remove an existing reservation.
  # Validates that the response returns status 201 on deletion,
  # then confirms the resource no longer exists with a GET returning 404.
  # =============================================================
  @TC03 @CRITICAL @deleteBooking
  Scenario: TC03 - Should delete an existing reservation and confirm it no longer exists — DELETE /booking/{id}

    # Request a session token by calling the reusable auth feature
    * def authResult = call read('classpath:support/auth.feature')
    * def token = authResult.token

    # Search for the booking by firstname to obtain its ID
    Given url bookingBaseUrl
    And path bookingEndpoint
    And param firstname = td.FirstName
    When method GET
    Then status 200
    # Extract the ID from the first result in the returned array
    * def bookingId = response[0].bookingid

    # Send the DELETE request using the session token for authorization
    Given url bookingBaseUrl
    And path bookingEndpoint + '/' + bookingId
    And header Cookie = 'token=' + token
    When method DELETE
    # Restful Booker returns 201 on successful deletion
    Then status 201
    * karate.log('Booking deleted successfully, ID:', bookingId)

    # Confirm the deleted booking no longer exists
    # A GET request to the same ID must return 404 Not Found
    Given url bookingBaseUrl
    And path bookingEndpoint + '/' + bookingId
    When method GET
    Then status 404
    * karate.log('Confirmed: booking no longer exists (404)')