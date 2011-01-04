@time @before
Feature: Finding log messages before a particular time
  As an Indy user I am able to find all log messages that have happened before a specified time

  Background:
    Given the following log:
    """
    2000-09-07 14:07:41 INFO  MyApp - Entering application.
    2000-09-07 14:07:42 DEBUG MyApp - Focusing application.
    2000-09-07 14:07:43 DEBUG MyApp - Blurring application.
    2000-09-07 14:07:44 WARN  MyApp - Low on Memory.
    2000-09-07 14:07:45 ERROR MyApp - Out of Memory.
    2000-09-07 14:07:46 INFO  MyApp - Exiting application.
    """


  Scenario: Count of entries before a specifed time
    When searching the log for all entries before the time 2000-09-07 14:07:44
    Then I expect to have found 3 log entries

  Scenario: Count of entries before and including a specifed time
    When searching the log for all entries before and including the time 2000-09-07 14:07:44
    Then I expect to have found 4 log entries

  Scenario: Particular entry before the specified time
    When searching the log for all entries before the time 2000-09-07 14:07:43
    Then I expect the last entry to be:
    """
    2000-09-07 14:07:42 DEBUG MyApp - Focusing application.
    """

  Scenario: No entries before the specified time
    When searching the log for all entries before the time 2000-09-07 14:07:40
    Then I expect to have found no log entries