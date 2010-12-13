@log_level
Feature: Finding log entries with a custom pattern
  As an Indy user I am able to find all log entries that match my custom log pattern

  Background:
    Given the following log:
    """
    14:07:41 INFO  MyApp#initialize - Entering application.
    14:07:42 DEBUG MyApp#panel - Focusing application.
    14:07:43 DEBUG MyApp#panel - Blurring application.
    14:07:44 WARN  MyApp#allocate - Low on Memory.
    14:07:45 ERROR MyApp#allocate - Out of Memory.
    14:07:46 INFO  MyApp#exit - Exiting application.
    """
    And the custom pattern (time,severity,application,method,message):
    """
    ^(\d{2}:\d{2}:\d{2})\s*(INFO|DEBUG|WARN|ERROR)\s*([^#]+)#([^\s]+)\s*-\s*(.+)$
    """
	
  Scenario: Count of entries at specified log level
    When searching the log for the log severity INFO
    Then I expect to have found 2 log entries
    
  
  Scenario: Particular entry at the specified log level
    When searching the log for the log severity INFO
    Then I expect the first entry to be:
    """
    14:07:41 INFO  MyApp#initialize - Entering application.
    """
    And I expect the last entry to be:
    """
    14:07:46 INFO  MyApp#exit - Exiting application.
    """
    
    
  Scenario: No entries at the specified log level
    When searching the log for the log severity SEVERE
    Then I expect to have found no log entries
    
    
  Scenario: Find entries at the custom field
    When searching the log for the exact match of custom field method "allocate"
    Then I expect to have found 2 log entries
    Then I expect the first entry to be:
    """
    14:07:44 WARN  MyApp#allocate - Low on Memory.
    """
    And I expect the last entry to be:
    """
    14:07:45 ERROR MyApp#allocate - Out of Memory.
    """