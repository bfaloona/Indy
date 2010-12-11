@log_level
Feature: Finding log entries at various log levels
  As an Indy user I am able to create an instance and find all logs at or above the log level.

  Background:
    Given the following log:
    """
    2000-09-07 14:07:41 INFO  MyApp - Entering application.
    2000-09-07 14:07:42 DEBUG MyApp - Focusing application.
    2000-09-07 14:07:43 DEBUG MyApp - Blurring application.
    2000-09-07 14:07:44 WARN  MyApp - Low on Memory.
    2000-09-07 14:07:45 ERROR MyApp - Out of Memory.
    2000-09-07 14:07:46 INFO  MyApp - Exiting application.
    """
    
  Scenario: Count of messages at a specified log level or higher
    When searching the log for the log severity INFO and higher
    Then I expect to have found 4 log entries
  

  Scenario: Count of messages at a specified log level or higher
    When searching the log for the log severity DEBUG and higher
    Then I expect to have found 6 log entries

    
  Scenario: Count of messages at a specified log level or lower
    When searching the log for the log severity INFO and lower
    Then I expect to have found 4 log entries

  
  Scenario: Particular message at a specified log level or higher
    When searching the log for the log severity INFO and higher
    Then I expect the first entry to be:
    """
    2000-09-07 14:07:41 INFO  MyApp - Entering application.
    """
    And I expect the last entry to be:
    """
    2000-09-07 14:07:46 INFO  MyApp - Exiting application.
    """