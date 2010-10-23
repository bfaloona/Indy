Feature: Finding log messages at a particular time
  As an Indy user I am able to create an instance and find all logs at a particular time.

  Background:
    Given the following log:
    """
    2000-09-07 14:07:41,508 [main] INFO  MyApp - Entering application.
    2000-09-07 14:07:41,529 [main] INFO  MyApp - Exiting application.
    """
    
    
  Scenario: Count of messages at specified time
    When Indy parses the log file
    Then I expect Indy to find 1 log entry at 2000-09-07 14:07:41,508
    
    
  Scenario: Particular message at the specified time
    When Indy parses the log file
    Then I expect the last 2000-09-07 14:07:41,508 entry to be:
    """
    2000-09-07 14:07:41,508 [main] INFO  MyApp - Entering application.
    """

    
  Scenario: No messages at the specified time
    When Indy parses the log file
    Then I expect Indy to find no log entries at 2000-09-07 14:07:41,507
    
    
  Scenario: No particular messages at the specified time
    When Indy parses the log file
    Then I expect the last 2000-09-07-14:07:41,507 to be nil