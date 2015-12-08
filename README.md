Indy: A Log Archaeology Tool
====================================

Synopsis
--------

[![build status](https://travis-ci.org/bfaloona/Indy.png)](http://travis-ci.org/bfaloona/Indy)

Log files are often searched for particular strings but are not often treated as data structures.  Indy attempts to deliver log content via more powerful features by allowing the ability to collect segments of a log from particular time; find a particular event; or monitor/reflect on a log to see if a particular event occurred (or not occurred).

Installation
------------

To install Indy use the following command:

    $ gem install indy

Usage
-----

## Basic Example (default log pattern)

    log = Indy.search(:file => './data.log').all.first.message
    # => "Entering APPLICATION."

## Custom Example

    # Given this log file:
    #
    # 2015/09/08 INFO #index Indexing application.
    # 2015/09/11 ERROR #search Searching application.
    # ...

    log_contents = File.open('./example.log', 'r').read
    pattern = /^(\d{4}\/\d{2}\/\d{2})\s+(INFO|DEBUG|WARN|ERROR)\s+(#\S+)\s+(.+)$/
    fields = [:time, :severity, :method, :message]
    custom_time_format = '%Y/%m/%d'

    indy = Indy.search(  :source => log_contents,
                         :entry_regexp => pattern,
                         :entry_fields => fields,
                         :time_format => custom_time_format
               )
    indy.after(:time => '2015/09/10').like(:severity => 'ERROR') do |entry|
        puts "#{entry.time} (#{entry.method}) #{entry.message}"
    end

## Specify your Source

### As a process or command

    Indy.search( {:cmd => 'ssh user@system "bash --login -c \"cat /var/log/standard.log\" "'} ).for(:severity => 'INFO')

### As a file

    Indy.search(file_object).for(:application => 'MyApp')
    Indy.search(:file => file_object).for(:application => 'MyApp')
    Indy.search(:file => '/log/data.log').for(:application => 'MyApp')

### As a string

    log_string = %{
        2000-09-07 14:07:41 INFO  MyApp - Entering application.
        2000-09-07 14:07:41 INFO  MyApp - Exiting application. }

    Indy.search(log_string).for(:message => 'Entering application')

## Log Pattern

### Default Log Format
  
The default log format follows this form:

    YYYY-MM-DD HH:MM:SS SEVERITY APPLICATION_NAME - MESSAGE

which uses this regular expression:
    
    /^(\d{4}.\d{2}.\d{2}\s+\d{2}.\d{2}.\d{2})\s+(TRACE|DEBUG|INFO|WARN|ERROR|FATAL)\s+(\w+)\s+-\s+(.+)$/

and specifies these fields:  
    
    [:time, :severity, :application, :message]

allowing searches like so:
    
    Indy.search(log_file).for(:severity => 'INFO')
    Indy.search(log_file).for(:application => 'MyApp', :severity => 'DEBUG')

### Custom Log Format

Brew your own log format!
To do so, specify an `:entry_regexp` pattern that captures each field you want to reference.
Also, specify an `:entry_fields` array of symbols that name the fields captured by your regexp.
If your date/time format differs from the default (%Y-%m-%d %H:%M:%S), you will need to specify a `:time_format` parameter.

    # If your log format is:
    # YYYY-MM-DD HH:MM:SS SEVERITY APPLICATION#METHOD - MESSAGE

    # Build a regexp pattern
    pattern = /^(\d{4}.\d{2}.\d{2}\s+\d{2}.\d{2}.\d{2})\s*(INFO|DEBUG|WARN|ERROR)\s*([^#]+)#([^\s]+)\s*-\s*(.+)$/
    # List the log fields
    fields = [:time,:severity,:application,:method,:message]

    # Use Indy#with to define your format
    Indy.search(source).with(:entry_regexp => pattern, :entry_fields => fields)

### Predefined Log Format

Several log formats have been predefined for ease of configuration. See indy/formats.rb

    # Indy::COMMON_LOG_FORMAT
    # Indy::COMBINED_LOG_FORMAT
    # Indy::LOG4R_DEFAULT_FORMAT
    #
    # Example (Log4r)
    #  INFO mylog: This is a message with level INFO
    Indy.new(:source => log_file).with(Indy::LOG4R_DEFAULT_FORMAT).for(:application => 'mylog')

### Multiline log entries

By default, Indy assumes that log lines are separated by new lines.
Any lines that don't match the active pattern are ignored.
To enable multiline log entries you MUST do these things:

1. Use `Indy.new()` and include the `:multiline => true` parameter
2. Use a log entry regexp that does not use `$` and/or `\n` to define the end of the entry.
3. Add a capture group that surrounds one full log entry.

#### Multiline Regexp tips

* Use non-greedy matching when needed: `.*?` instead of `.*`
* Assuming your log entries do not include a unique line ending, you can use a zero-width positive lookahead assertion to verify that each line is followed by the start of a valid log entry, or the end of the string. e.g.: if 'foo' starts each entry, use this assertion `(?=^foo|\z)` at the end of your `:entry_regexp`

Check out [Regexp Extensions](http://www.ruby-doc.org/docs/ProgrammingRuby/html/language.html#UN)

Example:

    # Given this log containing three entries:
    #
    # INFO MyApp - Multiline message begins here...
    # and ends here
    # DEBUG MyOtherApp - Single line message.
    # WARN MyOtherApp - A third entry.
    
    severity_string = 'DEBUG|INFO|WARN|ERROR|FATAL'

    multiline_regexp = /^((#{severity_string}) (\w+) - (.*?)(?=^#{severity_string}|\z))/

    # For reference, a single line regexp would be:
    #                  /^(#{severity_string}) (\w+) - (.*)$/


    Indy.new( :multiline => true,
              :entry_regexp => multiline_regexp,
              :entry_fields => [:severity, :application, :message],
              :source => MY_LOG
            )

### Explicit Time Format

If not specified, Indy tries to guess your time format (courtesy of DateTime#parse).
If you supply an explicit time format, it will use DateTime#strptime. If that fails, it will then guess with DateTime#parse.

This is required when log data uses a non-standard date format, e.g.: U.S. format 12-31-2000, and must be used in
conjunction with :entry_regexp and :entry_fields parameters.

    # 12-31-2011 Application starting
    Indy.new(   :time_format => '%m-%d-%Y',
                :source => LOG_FILE,
                :entry_regexp => /\d\d-\d\d-\d\d\d\d .*?/,
                :entry_fields => [:time, :message]
            ).all

Format directives are documented in [DateTime#strftime](http://ruby-doc.org/stdlib-2.0.0/libdoc/date/rdoc/DateTime.html#method-i-strftime).

## Match Criteria

### Exact Match

    Indy.search(source).for(:message => 'Entering Application')
    Indy.search(source).for(:severity => 'INFO')

### Exact Match with multiple parameters

    Indy.search(source).for(:message => 'Entering Application', :application => 'MyApp')
    Indy.search(source).for(:severity => 'INFO', :application => 'MyApp')

### Partial Match

    Indy.search(source).like(:message => 'Memory')

### Partial Match with multiple parameters

    Indy.search(source).like(:severity => '(?:INFO|DEBUG)', :message => 'Memory')

## Log Scopes

Multiple scope methods can be called on an instance. Use #reset_scope to remove scope constraints on the instance.

### Time Scope

    # After Dec 1
    Indy.search(source).after(:time => '2010-12-01 23:59:59').all

    # 20 minutes Around New Year's eve
    Indy.search(source).around(:time => '2011-01-01 00:00:00', :span => 20).all

    # After Jan 1 but Before Feb 1
    @log = Indy.search(source)
    @log.after(:time => '2011-01-01 00:00:00').before(:time => '2011-02-01 00:00:00')
    @log.all

    # Within Jan 1 and Feb 1 (same time scope as above)
    Indy.search(source).within(:start_time => '2011-01-01 00:00:00', :end_time =>'2011-02-01 00:00:00').all

    # After Jan 1
    @log = Indy.search(source)
    @log.after(:time => '2011-01-01 00:00:00')
    @log.all)
    # Reset the time scope to include entries before Jan 1
    @log.reset_scope
    # Before Feb 1
    @log.before(:time => '2011-02-01 00:00:00')
    @log.all

## Process the Results

An Array is returned by #for and #like, containing a Struct::Entry for each log entry.
The full entry is available with `entry.raw_entry`.

    entries = Indy.search(source).for(:message => 'Entering Application')
    entries.first.members
    # => ["time", "severity", "application", "message", "raw_entry"]

    Indy.search(source).for(:message => 'Entering Application').each do |entry|
      puts "[#{entry.time}] #{entry.message}: #{entry.application}"
    end

Contributing
------------

To get your improvements included, please fork and submit a pull request.
Bugs and/or failing tests are very appreciated.

Any suggestions about log formats to support, and/or intelligent defaults would be great.

To create a report in /coverage, run
    gem install simplecov
    COVERAGE=true rake test

Compatibility
-------------

Indy supports MacOS, *nix, and MS Windows and runs on the following ruby flavors:

  - 2.2.1
  - 1.9.3
  - 1.8.7
  - ree
  - jruby-1.7.20
  - rbx-2.2.7

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
