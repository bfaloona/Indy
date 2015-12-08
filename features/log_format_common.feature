@time @after
Feature: Finding log messages using the common log format
  As an Indy user I am able to find data in a file that uses common log format

  Background:
    Given the following log, using COMMON_LOG_FORMAT:
    """
    127.0.0.1 - frank [10/Oct/2010:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326
    127.0.0.1 - frank [11/Oct/2010:13:56:36 -0700] "GET /apache_aa.gif HTTP/1.0" 200 2327
    127.0.0.1 - sue [13/Oct/2010:13:56:37 -0700] "GET /apache_bb.gif HTTP/1.0" 200 2328
    127.0.0.1 - larry [14/Oct/2010:13:56:38 -0700] "GET /apache_cc.gif HTTP/1.0" 200 2329
    """
  Scenario: Count of entries after a specified time
    When searching the log for all entries after the time 2010-10-12 13:56:36
    Then I expect to have found 2 log entries

  Scenario: Count of entries before a COMMON formatted time
    When searching the log for all entries before the time 14/Oct/2010 13:56:37 -0700
    Then I expect to have found 3 log entries
