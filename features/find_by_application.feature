Feature: Finding log messages by application
  As an Indy user I am able to create an instance and find all logs related to a particular application.

  Background:
    Given the following log:
    """
    2000-09-07 14:07:41,508 [main] INFO  MyApp - Entering application.
    2000-09-07 14:07:41,529 [main] INFO  MyApp - Exiting application.
    """

    
  Scenario: Count of messages for a specific application
    When Indy parses the log file
    Then I expect Indy to find 2 log entry for 'MyApp'
    
    
  Scenario: Particular message for a specific application
    When Indy parses the log file
    Then I expect the first 'MyApp' entry to be:
    """
    2000-09-07 14:07:41,508 [main] INFO  MyApp - Entering application.
    """
    Then I expect the last 'MyApp' entry to be:
    """
    2000-09-07 14:07:41,529 [main] INFO  MyApp - Exiting application.
    """

    
  Scenario: No messages for a specific application
    When Indy parses the log file
    Then I expect Indy to find no log entries for 'YourApp'

    
  Scenario: No particular messages for a specific application
    When Indy parses the log file
    Then I expect the last 'YourApp' entry to be nil