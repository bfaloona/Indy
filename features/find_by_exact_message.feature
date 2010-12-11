@message
Feature: Finding log entries exactly matching a message
  As an Indy user I am able to create an instance and find all logs that exactly match a message.

  Background:
    Given the following log:
    """
    2000-09-07 14:07:41 INFO  MyApp - Entering application.
    2000-09-07 14:07:41 INFO  MyApp - Exiting application.
    """

    
  Scenario: Count of entries that exactly match the given message
    When searching the log for the exact match of the message "Entering application."
    Then I expect to have found 1 log entry


  Scenario: Particular entry that exactly matches a given message
    When searching the log for the exact match of the message "Entering application."
    Then I expect the first entry to be:
    """
    2000-09-07 14:07:41 INFO  MyApp - Entering application.
    """
    
    
  Scenario: No entries when no messages exactly match
    When searching the log for the exact match of the message "Opening application."
    Then I expect to have found no log entries


  Scenario: No entries when even when there is a partial match
    When searching the log for the exact match of the message "application"
    Then I expect to have found no log entries