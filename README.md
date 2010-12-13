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

**0. Require Indy and Load your Log**

Indy currently requires that the log data already be loaded. 

    require 'indy'
    source_string = IO.readlines("/var/log/logfile.log")

The default search pattern resembles something might find:

    YYYY-MM-DD HH:MM:SS SEVERITY APPLICATION_NAME - MESSAGE

**1. Exact Match**
  
   Indy.search(source_string).for(:severity => 'INFO')
   Indy.search(source_string).for(:application => 'MyApp', :severity => 'DEBUG')

**2. Partial Match**

   Indy.search(source_string).like(:message => 'Memory')
   Indy.search(source_string).like(:severity => '(?:INFO|DEBUG)', :message => 'Memory')

**3. Custom Log Pattern**

The default pattern is obviously not strong enough for you, brew your own:

    # HH:MM:SS SEVERITY APPLICATION#METHOD - MESSAGE
    custom_pattern = "^(\d{2}:\d{2}:\d{2})\s*(INFO|DEBUG|WARN|ERROR)\s*([^#]+)#([^\s]+)\s*-\s*(.+)$"
    Indy.search(source_string).with(custom_pattern,:time,:severity,:application,:method,:message).for(:severity => 'INFO', :method => 'allocate')
    

LICENSE
-------

(The MIT License)

Copyright (c) 2010 FIX

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