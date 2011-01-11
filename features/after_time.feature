@time @after
Feature: Finding log messages after a particular time
  As an Indy user I am able to find all log messages that have happened after a specified time

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


  Scenario: Count of entries after a specified time
    When searching the log for all entries after the time 2000-09-07 14:07:44
    Then I expect to have found 2 log entries

  Scenario: Count of entries after and including a specified time
    When searching the log for all entries after and including the time 2000-09-07 14:07:44
    Then I expect to have found 3 log entries


  Scenario: Count of entries after a specified time
    When searching the log for all entries after the time 2000-09-07 14:07:40
    Then I expect to have found 6 log entries


  Scenario: Particular entry after the specified time
    When searching the log for all entries after the time 2000-09-07 14:07:41
    Then I expect the first entry to be:
    """
    2000-09-07 14:07:42 DEBUG MyApp - Focusing application.
    """


  Scenario: No entries after the specified time
    When searching the log for all entries after the time 2000-09-07 14:07:50
    Then I expect to have found no log entries