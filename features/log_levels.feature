Feature: Finding log messages at log levels
  As an Indy user I am able to create an instance and find all logs at the various standard log levels.

  Background:
    Given the following log:
    """
    2000-09-07 14:07:41,508 [main] INFO  MyApp - Entering application.
    2000-09-07 14:07:41,529 [main] INFO  MyApp - Exiting application.
    """
    
  Scenario: Count of messages at specified log level
    When Indy parses the log file
    Then I expect Indy to find 2 INFO log entries
    
  
  Scenario: Particular message at the specified log level
    When Indy parses the log file
    Then I expect the last INFO entry to be:
    """
    2000-09-07 14:07:41,508 [main] INFO  MyApp - Entering application.
    """
    And I expect the last INFO entry to be:
    """
    2000-09-07 14:07:41,529 [main] INFO  MyApp - Exiting application.
    """
    
    
  Scenario: No messages at the specified log level
    When Indy parses the log file
    Then I expect Indy to find no DEBUG log entries
    
    
  Scenario: No particular messages at the specified log level
    When Indy parses the log file
    Then I expect the last DEBUG log entry to be nil