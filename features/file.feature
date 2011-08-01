@application
Feature: Finding log entries in a file

  Background:
    Given the following log file:
    """
    spec/data.log
    """

    
  Scenario: Count of entries for a specific application
    When searching the log for the application 'MyApp'
    Then I expect to have found 2 log entries
    
    
  Scenario: Particular entry for a specific application
    When searching the log for the application 'MyApp'
    Then I expect the first entry to be:
    """
    2000-09-07 14:07:41 INFO  MyApp - Entering application.
    """
    Then I expect the last entry to be:
    """
    2000-09-07 14:07:41 INFO  MyApp - Exiting application.
    """

    
  Scenario: No entries for a specific application
    When searching the log for the application 'YourApp'
    Then I expect to have found no log entries