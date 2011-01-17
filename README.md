Indy: A Log Archaeology Tool
====================================

Synopsis
--------

Log files are often searched for particular strings but it does not often treat the logs themselves as data structures.  Indy attempts to deliver logs with more powerful features by allowing the ability: to collect segments of a log from particular time; find a particular event; or monitor/reflect on a log to see if a particular event occurred (or not occurred).

Installation
------------

To install Indy use the following command:

    $ gem install indy
    
(Add `sudo` if you're installing under a POSIX system as root)

Usage
-----

## Require Indy

    require 'indy'

## Specify your Source

### As a process or command

    Indy.search( {:cmd => 'ssh user@system "bash --login -c \"cat /var/log/standard.log\" "'} ).for(:severity => 'INFO')

### As a file

    Indy.search('logpath/output.log').for(:application => 'MyApp')

### As a string

    log_string = %{
        2000-09-07 14:07:41 INFO  MyApp - Entering application.
        2000-09-07 14:07:41 INFO  MyApp - Exiting application. }

    Indy.search(log_string).for(:message => 'Entering application')

## Specify your Pattern

The default search pattern resembles something you might find:

    YYYY-MM-DD HH:MM:SS SEVERITY APPLICATION_NAME - MESSAGE

### Default Log Pattern
  
   Indy.search(source).for(:severity => 'INFO')
   Indy.search(source).for(:application => 'MyApp', :severity => 'DEBUG')

### Custom Log Pattern

If the default pattern is obviously not strong enough for you, brew your own.
To do so, specify a pattern and each of the match with their symbolic name.

    # HH:MM:SS SEVERITY APPLICATION#METHOD - MESSAGE
    custom_pattern = /^(\d{2}:\d{2}:\d{2})\s*(INFO|DEBUG|WARN|ERROR)\s*([^#]+)#([^\s]+)\s*-\s*(.+)$/

    Indy.search(source).with(custom_pattern,:time,:severity,:application,:method,:message).for(:severity => 'INFO', :method => 'allocate')

### Predefined Log Patterns

Several log formats have been predefined for ease of configuration. See indy/patterns.rb

    # Indy::COMMON_LOG_PATTERN
    # Indy::COMBINED_LOG_PATTERN
    # Indy::LOG4R_DEFAULT_PATTERN
    #
    # Example (Log4r)
    #  INFO mylog: This is a message with level INFO
    Indy.new(:source => 'logfile.txt', :pattern => Indy::LOG4R_DEFAULT_PATTERN).for(:application => 'mylog')

### Explicit Time Format

By default, Indy tries to guess your time format (courtesy of DateTime#parse). If you supply an explicit time format, it will use DateTime#strptime, as well as try to guess.

This is required when log data uses a non-standard date format, e.g.: U.S. format 12-31-2000

    # 12-31-2011 23:59:59
    Indy.new(:time_format => '%m-%d-%Y %H:%M:%S', :source => LOG_FILE).for(:all)

## Match Criteria

### Exact Match

    Indy.search(source).for(:message => 'Entering Application')
    Indy.search(source).for(:severity => 'INFO')

### Exact Match with multiple parameters

    Indy.search(source).for(:message => 'Entering Application', :application => 'MyApp')
    Indy.search(source).for(:severity => 'INFO', :application => 'MyApp')

### Time Scope

    Indy.search(source).after(:time => '2011-01-13 13:40:00').for(:all)
    Indy.search(source).before(:time => '2010-12-31 23:59:59').for(:all)
    Indy.search(source).around(:time => '2011-01-01 00:00:00', :span => 2).for(:all) # 2 minutes around New Year's Eve
    Indy.search(source).within(:time => ['2011-01-01 00:00:00','2011-02-01 00:00:00']).for(:severity => 'ERROR', :application => 'MyApp')

### Partial Match

    Indy.search(source).like(:message => 'Memory')

### Partial Match with multiple parameters

    Indy.search(source).like(:severity => '(?:INFO|DEBUG)', :message => 'Memory')

## Process the Results

    A ResultSet (Array) is returned by #for, #like, #after, etc.

    entries = Indy.search(source).for(:message => 'Entering Application')

    Indy.search(source).for(:message => 'Entering Application').each do |entry|

      # each log line entry returned is an OpenStruct object
      puts "[#{entry.time}] #{entry.message}: #{entry.application}"

    end

LICENSE
-------

(The MIT License)

Copyright (c) 2010 Franklin Webber

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.