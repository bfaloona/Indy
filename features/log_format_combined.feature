@time @after
Feature: Finding log messages using the combined log format
  As an Indy user I am able to find data in a file that uses common log format

  Background:
    Given the following log, using COMBINED_LOG_FORMAT:
    """
    127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"
    127.0.0.2 - adam [12/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"
    127.0.0.3 - larry [13/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"
    """

  Scenario: Count of entries after a specified time
    When searching the log for all entries after the time 2000-10-11 11:00:01
    Then I expect to have found 2 log entries
