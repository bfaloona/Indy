@application @message @log_level @time
Feature: Finding log entries that match multiple fields
  As an Indy user I am able to create an instance and find all logs related to a particular application.

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
    
  Scenario: Count of entries that partially matches the message and the log level
    When searching the log for entries like:
      | message     | severity    |
      | application | INFO\|DEBUG |
    Then I expect to have found 4 log entries
    
    
  Scenario: Particular entry that partially matches two message but only one log level
    When searching the log for entries like:
      | Message    | severity |
      | [Mm]emory  | ERROR    |
    Then I expect to have found 1 log entry  
    And I expect the first entry to be:
    """
    2000-09-07 14:07:45 ERROR MyApp - Out of Memory.
    """


  Scenario: No entries for when looking at a matching time but no application
    When searching the log for:
      | time                | application |
      | 2000-09-07 14:07:46 | YourApp     |
    Then I expect to have found no log entries