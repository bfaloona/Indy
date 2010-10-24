Feature: Finding log entries at an exact log level
  As an Indy user I am able to create an instance and find all logs at the various standard log levels.

  Background:
    Given the following log:
    """
    2000-09-07 14:07:41,508 [main] INFO  MyApp - Entering application.
    2000-09-07 14:07:42,608 [main] DEBUG MyApp - Focusing application.
    2000-09-07 14:07:43,778 [main] DEBUG MyApp - Blurring application.
    2000-09-07 14:07:44,778 [main] WARN MyApp - Low on Memory.
    2000-09-07 14:07:45,778 [main] ERROR MyApp - Out of Memory.
    2000-09-07 14:07:46,529 [main] INFO  MyApp - Exiting application.
    """
	
  Scenario: Count of entries at specified log level
    When Indy parses the log file for log severity INFO
    Then I expect Indy to find 2 INFO log entries
    
  
  Scenario: Particular entry at the specified log level
    When Indy parses the log file for log severity INFO
    Then I expect the first entry to be:
    """
    2000-09-07 14:07:41,508 [main] INFO  MyApp - Entering application.
    """
    And I expect the last entry to be:
    """
    2000-09-07 14:07:41,529 [main] INFO  MyApp - Exiting application.
    """
    
    
  Scenario: No entries at the specified log level
    When Indy parses the log file for log severity SEVERE
    Then I expect Indy to have found no log entries
    
    
  Scenario: No particular entries at the specified log level
    When Indy parses the log file for the log severity SEVERE
    Then I expect there not to be any entries