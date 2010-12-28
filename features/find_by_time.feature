@application
Feature: Finding log entries by time
  As an Indy user I am able to create an instance and find all logs by various time references.

  Background:
    Given the following log:
    """
    2000-09-07 14:07:41 INFO  MyApp - Entering application.
    2000-09-07 14:07:47 INFO  MyApp - Exiting application.
    2000-09-08 12:07:47 INFO  SomeOtherApp - Error message 1.
    2000-09-08 14:08:41 INFO  SomeOtherApp - Error message 2.
    2000-09-08 14:09:41 INFO  MyApp - Entering application.
    2000-09-09 04:07:41 INFO  MyApp - Exiting application.
    2000-09-09 05:07:41 INFO  MyApp - Entering application.
    """

    
  Scenario: Count of entries for the second half of the log
    When searching the log for entries in the second half, by time
    Then I expect to have found 5 log entries
    
  Scenario: Count of entries for the first half of the log
    When searching the log for entries in the first half, by time
    Then I expect to have found 2 log entries

    
#  Scenario: Particular entry for a specific application
#    When searching the log for the application 'MyApp'
#    Then I expect the first entry to be:
#    """
#    2000-09-07 14:07:41 INFO  MyApp - Entering application.
#    """
#    Then I expect the last entry to be:
#    """
#    2000-09-07 14:07:41 INFO  MyApp - Exiting application.
#    """
#
#
#  Scenario: No entries for a specific application
#    When searching the log for the application 'YourApp'
#    Then I expect to have found no log entries