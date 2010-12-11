@time
Feature: Finding log messages at a particular time
  As an Indy user I am able to create an instance and find all logs at an exact time.

  Background:
    Given the following log:
    """
    2000-09-07 14:07:41 INFO  MyApp - Entering application.
    2000-09-07 14:07:42 INFO  MyApp - Exiting application.
    """
    
    
  Scenario: Count of entries at the specified time
    When searching the log for the time 2000-09-07 14:07:41
    Then I expect to have found 1 log entry
    
    
  Scenario: Particular entry at the specified time
    When searching the log for the time 2000-09-07 14:07:41
    Then I expect the last entry to be:
    """
    2000-09-07 14:07:41 INFO  MyApp - Entering application.
    """

    
  Scenario: No entries at the specified time
    When searching the log for the time 2000-09-07 14:07:40
    Then I expect to have found no log entries