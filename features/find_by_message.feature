Feature: Finding log messages by message
  As an Indy user I am able to create an instance and find all logs related to a particular message or portion of a message.

  Background:
    Given the following log:
    """
    2000-09-07 14:07:41,508 [main] INFO  MyApp - Entering application.
    2000-09-07 14:07:41,529 [main] INFO  MyApp - Exiting application.
    """

    
  Scenario: Count of entries that match a particular message
    When Indy parses the log file
    Then I expect Indy to find 1 log entry that matched the message 'Entering'
    
    
  Scenario: Particular log entry that matches a particular message
    When Indy parses the log file
    Then I expect the first entry that matches the message 'Entering' to be:
    """
    2000-09-07 14:07:41,508 [main] INFO  MyApp - Entering application.
    """
    
    
  Scenario: No entries when no messages match
    When Indy parses the log file
    Then I expect Indy to find no log entries that match the message 'Opening'

    
  Scenario: No particular entries when no messages match
    When Indy parses the log file
    Then I expect the last entry that matches the message 'Opening' to be nil