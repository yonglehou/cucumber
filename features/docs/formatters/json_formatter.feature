Feature: JSON output formatter
  In order to simplify processing of Cucumber features and results
  Developers should be able to consume features as JSON

  Background:
    Given the standard step definitions
    And a file named "features/one_passing_one_failing.feature" with:
      """
      @a
      Feature: One passing scenario, one failing scenario

        @b
        Scenario: Passing
          Given this step passes

        @c
        Scenario: Failing
          Given this step fails
      """
    And a file named "features/step_definitions/json_steps.rb" with:
      """
      Given /^I embed a screenshot/ do
        File.open("screenshot.png", "w") { |file| file << "foo" }
        embed "screenshot.png", "image/png"
      end
      """
    And a file named "features/embed.feature" with:
      """
      Feature: A screenshot feature

        Scenario:
          Given I embed a screenshot

      """

  # Need to investigate why this won't pass in-process. error_message doesn't get det?
  @spawn
  Scenario: one feature, one passing scenario, one failing scenario
    When I run `cucumber --format json features/one_passing_one_failing.feature`
    Then it should fail with JSON:
      """
      [
        {
          "uri": "features/one_passing_one_failing.feature",
          "keyword": "Feature",
          "id": "one-passing-scenario,-one-failing-scenario",
          "name": "One passing scenario, one failing scenario",
          "line": 2,
          "description": "",
          "tags": [
            {
              "name": "@a",
              "line": 1
            }
          ],
          "elements": [
            {
              "keyword": "Scenario",
              "id": "one-passing-scenario,-one-failing-scenario;passing",
              "name": "Passing",
              "line": 5,
              "description": "",
              "tags": [
                {
                  "name": "@b",
                  "line": 4
                }
              ],
              "type": "scenario",
              "steps": [
                {
                  "keyword": "Given ",
                  "name": "this step passes",
                  "line": 6,
                  "match": {
                    "location": "features/step_definitions/steps.rb:1"
                  },
                  "result": {
                    "status": "passed",
                    "duration": 1
                  }
                }
              ]
            },
            {
              "keyword": "Scenario",
              "id": "one-passing-scenario,-one-failing-scenario;failing",
              "name": "Failing",
              "line": 9,
              "description": "",
              "tags": [
                {
                  "name": "@c",
                  "line": 8
                }
              ],
              "type": "scenario",
              "steps": [
                {
                  "keyword": "Given ",
                  "name": "this step fails",
                  "line": 10,
                  "match": {
                    "location": "features/step_definitions/steps.rb:4"
                  },
                  "result": {
                    "status": "failed",
                    "error_message": " (RuntimeError)\n./features/step_definitions/steps.rb:4:in `/^this step fails$/'\nfeatures/one_passing_one_failing.feature:10:in `Given this step fails'",
                    "duration": 1
                  }
                }
              ]
            }
          ]
        }
      ]

      """

  @spawn
  Scenario: one feature, one passing scenario, one failing scenario with prettyfied json
    When I run `cucumber --format json_pretty features/one_passing_one_failing.feature`
    Then it should fail with JSON:
      """
      [
        {
          "uri": "features/one_passing_one_failing.feature",
          "keyword": "Feature",
          "id": "one-passing-scenario,-one-failing-scenario",
          "name": "One passing scenario, one failing scenario",
          "line": 2,
          "description": "",
          "tags": [
            {
              "name": "@a",
              "line": 1
            }
          ],
          "elements": [
            {
              "keyword": "Scenario",
              "id": "one-passing-scenario,-one-failing-scenario;passing",
              "name": "Passing",
              "line": 5,
              "description": "",
              "tags": [
                {
                  "name": "@b",
                  "line": 4
                }
              ],
              "type": "scenario",
              "steps": [
                {
                  "keyword": "Given ",
                  "name": "this step passes",
                  "line": 6,
                  "match": {
                    "location": "features/step_definitions/steps.rb:1"
                  },
                  "result": {
                    "status": "passed",
                    "duration": 1
                  }
                }
              ]
            },
            {
              "keyword": "Scenario",
              "id": "one-passing-scenario,-one-failing-scenario;failing",
              "name": "Failing",
              "line": 9,
              "description": "",
              "tags": [
                {
                  "name": "@c",
                  "line": 8
                }
              ],
              "type": "scenario",
              "steps": [
                {
                  "keyword": "Given ",
                  "name": "this step fails",
                  "line": 10,
                  "match": {
                    "location": "features/step_definitions/steps.rb:4"
                  },
                  "result": {
                    "status": "failed",
                    "error_message": " (RuntimeError)\n./features/step_definitions/steps.rb:4:in `/^this step fails$/'\nfeatures/one_passing_one_failing.feature:10:in `Given this step fails'",
                    "duration": 1
                  }
                }
              ]
            }
          ]
        }
      ]

      """

  @spawn
  Scenario: DocString
    Given a file named "features/doc_string.feature" with:
      """
      Feature: A DocString feature

        Scenario:
          Then I should fail with
            \"\"\"
            a string
            \"\"\"
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Then /I should fail with/ do |s|
        raise s
      end
      """
    When I run `cucumber --format json features/doc_string.feature`
    Then it should fail with JSON:
      """
      [
        {
          "id": "a-docstring-feature",
          "uri": "features/doc_string.feature",
          "keyword": "Feature",
          "name": "A DocString feature",
          "line": 1,
          "description": "",
          "elements": [
            {
              "id": "a-docstring-feature;",
              "keyword": "Scenario",
              "name": "",
              "line": 3,
              "description": "",
              "type": "scenario",
              "steps": [
                {
                  "keyword": "Then ",
                  "name": "I should fail with",
                  "line": 4,
                  "doc_string": {
                    "content_type": "",
                    "value": "a string",
                    "line": 5
                  },
                  "match": {
                    "location": "features/step_definitions/steps.rb:1"
                  },
                  "result": {
                    "status": "failed",
                    "error_message": "a string (RuntimeError)\n./features/step_definitions/steps.rb:2:in `/I should fail with/'\nfeatures/doc_string.feature:4:in `Then I should fail with'",
                    "duration": 1
                  }
                }
              ]
            }
          ]
        }
      ]
      """

  @wip-new-core
  Scenario: embedding screenshot
    When I run `cucumber -b --format json features/embed.feature`
    Then it should pass with JSON:
    """
    [
      {
        "uri": "features/embed.feature",
        "id": "a-screenshot-feature",
        "keyword": "Feature",
        "name": "A screenshot feature",
        "line": 1,
        "description": "",
        "elements": [
          {
            "id": "a-screenshot-feature;",
            "keyword": "Scenario",
            "name": "",
            "line": 3,
            "description": "",
            "type": "scenario",
            "steps": [
              {
                "keyword": "Given ",
                "name": "I embed a screenshot",
                "line": 4,
                "embeddings": [
                  {
                    "mime_type": "image/png",
                    "data": "Zm9v"
                  }
                ],
                "match": {
                  "location": "features/step_definitions/json_steps.rb:1"
                },
                "result": {
                  "status": "passed",
                  "duration": 1
                }
              }
            ]
          }
        ]
      }
    ]

    """
