@time @within
Feature: Finding log messages within a particular time
  As an Indy user I am able to find all log messages that have happened between two specified times

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


  Scenario: Count of entries between the specified times
    When searching the log for all entries between the time 2000-09-07 14:07:44 and 2000-09-07 14:07:46
    Then I expect to have found 1 log entries

  Scenario: Count of entries between and including the specified times
    When searching the log for all entries between and including the times 2000-09-07 14:07:44 and 2000-09-07 14:07:46
    Then I expect to have found 3 log entries


  Scenario: Count of entries between the specified times
    When searching the log for all entries between the time 2000-09-07 14:07:40 and 2000-09-07 14:07:50
    Then I expect to have found 6 log entries


  Scenario: Particular entry between the specified times
    When searching the log for all entries between the time 2000-09-07 14:07:40 and 2000-09-07 14:07:50
    Then I expect the last entry to be:
    """
    2000-09-07 14:07:46 INFO  MyApp - Exiting application.
    """


  Scenario: No entries between the specified times
    When searching the log for all entries between the time 2000-09-07 14:07:50 and 2000-09-07 14:07:55
    Then I expect to have found no log entries