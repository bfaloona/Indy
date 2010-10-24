Feature: Finding log entries by application
  As an Indy user I am able to create an instance and find all logs related to a particular application.

  Background:
    Given the following log:
    """
    2000-09-07 14:07:41,508 [main] INFO  MyApp - Entering application.
    2000-09-07 14:07:41,529 [main] INFO  MyApp - Exiting application.
    """

    
  Scenario: Count of entries for a specific application
    When Indy parses the log file for the application 'MyApp'
    Then I expect Indy to find 2 log entries
    
    
  Scenario: Particular entry for a specific application
    When Indy parses the log file for the application 'MyApp'
    Then I expect the first entry to be:
    """
    2000-09-07 14:07:41,508 [main] INFO  MyApp - Entering application.
    """
    Then I expect the last entry to be:
    """
    2000-09-07 14:07:41,529 [main] INFO  MyApp - Exiting application.
    """

    
  Scenario: No entries for a specific application
    When Indy parses the log file for the application 'MyApp'
    Then I expect Indy to have found no log entries

    
  Scenario: No particular entries for a specific application
    When Indy parses the log file for the application 'MyApp'
    Then I expect there not to be any entries