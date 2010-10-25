Feature: Finding log messages by message
  As an Indy user I am able to create an instance and find all logs related to a particular message or portion of a message.

  Background:
    Given the following log:
    """
    2000-09-07 14:07:41 INFO  MyApp - Entering application.
    2000-09-07 14:07:41 INFO  MyApp - Exiting application.
    """

    
  Scenario: Count of entries that partially match a given message
    When searching the log for matches of the message "Entering"
    Then I expect to have found 1 log entry
    
    
  Scenario: Particular entry that partially match a given message
    When searching the log for matches of the message "Entering"
    Then I expect the first entry to be:
    """
    2000-09-07 14:07:41 INFO  MyApp - Entering application.
    """
    
    
  Scenario: No entries when no entries partially match the message 
    When searching the log for matches of the message "Opening"
    Then I expect to have found no log entries