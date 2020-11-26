# Add

## Overview

`tf_fp_add.rb` is used to add new directories to `persistent/directories`. Doing so changes their status from "unlisted" to "uncomplete" for status purposes.

As only tracked directories can be marked as complete, this command is the first step in performing a folder pass and allows you to designate directories that you wish to process in some way, before marking them as complete.

## Arguments

`--directory=[DIRECTORY]`  
*Optional, multiple*  
The target directory to add. If this argument is not specified, the current directory is used instead.

`--recursive`  
*Optional, single*  
Also adds directories below target directory, subject to blacklist exclusion.

`--help`  
*Optional, single*  
Shows command line arguments instead of executing.

## Sample Output

### Adding one or more directories

1 directory is added, bring the total tracked directories to 3.
```
$ tf_fp_add.rb

Directories added : 1 ( 2 => 3 )
```

### Resetting directories

Aside from adding 1 untracked directory, 1 tracked and complete directory has been reset to uncomplete, brining the total complete directories down to 0.
```
$ tf_fp_add.rb -r

Directories added : 1 ( 4   => 5   )
Directories reset : 1 ( 1/4 => 0/5 )
```

### Log file creation

Whenever a log file is created, the command line output will show the file path of the new log.
```
$ tf_fp_add.rb -r

Directories added : 2 ( 3 => 5 )
File Created      : persistent/logs/2014-07-11.csv
File Created      : persistent/logs/summary.csv
```
