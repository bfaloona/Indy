Feature: Finding log entries exactly matching a message
  As an Indy user I am able to create an instance and find all logs that exactly match a message.

  Background:
    Given the following log:
    """
    2000-09-07 14:07:41,508 [main] INFO  MyApp - Entering application.
    2000-09-07 14:07:41,529 [main] INFO  MyApp - Exiting application.
    """

    
  Scenario: Count of entries that exactly match the given message
    When Indy parses the log file for the exact match of the message "Entering application."
    Then I expect to have found 1 log entry
    
    
  Scenario: Particular entry that exactly matches a given message
    When Indy parses the log file for the exact match of the message "Entering application."
    Then I expect the first entry to be:
    """
    2000-09-07 14:07:41,508 [main] INFO  MyApp - Entering application.
    """
    
    
  Scenario: No entries when no messages exactly match
    When Indy parses the log file for the exact match of the message "Opening application."
    Then I expect to have found 0 log entries

    
  Scenario: No particular entries when no messages match
    When Indy parses the log file for the exact match of the message "Opening application."
    Then I expect there not to be any entries