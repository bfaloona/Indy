@time @around
Feature: Finding log messages around a particular time
  As an Indy user I am able to find all log messages that have happened around a specified time

  Background:
    Given the following log:
      """
      2000-09-07 14:07:41 INFO  MyApp - Entering application.
      2000-09-07 14:17:43 DEBUG MyApp - Focusing application.
      2000-09-07 14:27:43 DEBUG MyApp - Blurring application.
      2000-09-07 14:37:43 WARN  MyApp - Low on Memory.
      2000-09-07 14:47:43 ERROR MyApp - Out of Memory.
      2000-09-07 14:57:46 INFO  MyApp - Exiting application.
      """

  Scenario: Count of entries for a time span around a specified time
    When searching the log for all entries 31 minutes around the time 2000-09-07 14:27:43
    Then I expect to have found 3 log entries

  Scenario: Count of entries for a time span before a specified time
    When searching the log for all entries 11 minutes before the time 2000-09-07 14:27:43
    Then I expect to have found 1 log entries

  Scenario: Count of entries for a time span after a specified time
    When searching the log for all entries 31 minutes after the time 2000-09-07 14:27:43
    Then I expect to have found 3 log entries

Scenario: Count of entries for a time span before and including a specified time
    When searching the log for all entries 11 minutes before and including the time 2000-09-07 14:47:43
    Then I expect to have found 2 log entries

  Scenario: Count of entries for a time span after and including a specified time
    When searching the log for all entries 30 minutes after and including the time 2000-09-07 14:17:43
    Then I expect to have found 4 log entries
