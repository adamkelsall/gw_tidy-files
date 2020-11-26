# Complete

## Overview

`tf_fp_complete.rb` is used to mark directories listed in `persistent/directories` as complete. As long as the directory is listed and its status is "uncomplete", it will be marked as "complete".

This script is to be used to mark directories that you have finished processing manually or by other means, making it clear to you later which directories you have completed.

## Arguments

`--directory=[DIRECTORY]`  
*Optional, multiple*  
The target directory to complete. If this argument is not specified, the current directory is used instead.

`--recursive`  
*Optional, single*  
Also completes directories below target directory, subject to blacklist exclusion.

`--help`  
*Optional, single*  
Shows command line arguments instead of executing.

## Sample Output

### Completing one or more directories

1 directory is completed, bring the total completed directories to 3.
```
$ tf_fp_add.rb

Directories completed : 1 ( 2 => 3 )
```

### Log file creation

Whenever a log file is created, the command line output will show the file path of the new log.
```
$ tf_fp_complete.rb

Directories completed : 1 ( 2 => 3 )
File Created          : persistent/logs/2014-07-11.csv
File Created          : persistent/logs/summary.csv
```
