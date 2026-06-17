# =============================================================
# ATC01_Posts.feature
#
# @author Osiris Montiel Campos
# @Epic    Automation Framework API
# @Feature API Endpoint Validation (JSONPlaceholder /posts)
# =============================================================
Feature: API Posts — CRUD Operations and Schema Validation

  Background:
    # Load functional test data from external JSON resource
    * def td = read('classpath:support/testdata-posts.json').ATC01_ApiOne

  # =============================================================
  # TC01 — shouldGetPostById
  # @Story Retrieve a single post
  # @Severity CRITICAL
  # =============================================================
  @TC01 @CRITICAL
  Scenario: TC01 - GET /posts/{id} should return the correct record matching the ID

    Given url apiOneBaseUrl
    And path postsEndpoint, td.Id
    When method GET

    Then status 200
    And match response.id    == td.Id
    And match response.title != null
    And match response.body  != null


  # =============================================================
  # TC02 — shouldGetPostsByUserId
  # @Story Filter posts by user
  # @Severity NORMAL
  # =============================================================
  @TC02 @NORMAL
  Scenario: TC02 - GET /posts?userId={id} should return a filtered list belonging only to the user

    Given url apiOneBaseUrl
    And path postsEndpoint
    And param userId = td.UserId
    When method GET

    Then status 200
    And match response == '#[_ > 0]'
    And match each response == { userId: '#(td.UserId)', id: '#number', title: '#string', body: '#string' }


  # =============================================================
  # TC03 — shouldReturn404ForNonExistentPost
  # @Story Handle non-existent resource
  # @Severity NORMAL
  # =============================================================
  @TC03 @NORMAL
  Scenario: TC03 - GET /posts/{invalidId} should return 404 Not Found

    Given url apiOneBaseUrl
    And path postsEndpoint, td.Id_2
    When method GET

    Then status 404


  # =============================================================
  # TC04 — shouldCreatePost
  # @Story Create a new post
  # @Severity CRITICAL
  # =============================================================
  @TC04 @CRITICAL
  Scenario: TC04 - POST /posts should create a new resource and return 201 Created

    Given url apiOneBaseUrl
    And path postsEndpoint
    And header Content-Type = contentType
    And request
      """
      {
        "title":  "My first automated post",
        "body":   "This is the post body",
        "userId": #(td.UserId)
      }
      """
    When method POST
    Then status 201
    And match response.id != null


  # =============================================================
  # TC05 — shouldUpdatePost
  # @Story Update an existing post
  # @Severity NORMAL
  # =============================================================
  @TC05 @NORMAL
  Scenario: TC05 - PUT /posts/{id} should fully update the target resource

    Given url apiOneBaseUrl
    And path postsEndpoint, td.Id
    And header Content-Type = contentType
    And request
      """
      {
        "title":  "Updated title",
        "body":   "Updated body",
        "userId": #(td.UserId)
      }
      """
    When method PUT
    Then status 200
    And match response.id    == td.Id
    And match response.title == 'Updated title'


  # =============================================================
  # TC06 — shouldDeletePost
  # @Story Delete an existing post
  # @Severity NORMAL
  # =============================================================
  @TC06 @NORMAL
  Scenario: TC06 - DELETE /posts/{id} should delete the resource and return 200 OK

    Given url apiOneBaseUrl
    And path postsEndpoint, td.Id
    When method DELETE
    Then status 200


  # =============================================================
  # TC07 — shouldMatchPostSchema
  # @Story Validate post response schema
  # @Severity CRITICAL
  # =============================================================
  @TC07 @CRITICAL
  Scenario: TC07 - GET /posts/{id} should match the defined JSON schema structure

    Given url apiOneBaseUrl
    And path postsEndpoint, td.Id
    When method GET
    Then status 200

    # Native Gherkin structural validation (removes the need for third-party schema validation libraries)
    And match response ==
      """
      {
        "userId": '#number',
        "id":     '#number',
        "title":  '#string',
        "body":   '#string'
      }
      """