# Status

## Overview

`tf_fp_status.rb` provides detailed information on the status of directories, in order to allow you to see which directories you still need to process. The goal is to make it easy to navigate your directories and see which areas of your directory structure still have work to be done on.

All directories are either unlisted, uncomplete or complete. See [How It Works](how_it_works.md) for more info.

## Arguments

`--directory=[DIRECTORY]`  
*Optional, multiple*  
The target directory to show status info for. If this argument is not specified, the current directory is used instead.

`--recursive`  
*Optional, single*  
Shows additional information about all directories below the target directory, subject to blacklist exclusion.

`--breakdown`  
*Optional, single, requires --recursive*  
Shows detailed status info about each directory below the target directory. This includes listing all statuses found below each subdirectory. See below for comprehensive examples.

## Sample Output

### No arguments
Without arguments, the status of the target directory is displayed, and nothing else.
```
$ tf_fp_status.rb

This directory : Unlisted
```

### Recursive argument
Aside from the status of the target directory, the `--recursvie` argument displays overall statistics for its contents, not including itself.
```
$ tf_fp_status.rb -r

This directory           : Uncomplete

Directories unlisted     : 9  / 29.0%
Directories uncomplete   : 15 / 48.4%
Directories complete     : 7  / 22.6%
```

### Recursive and breakdown arguments
High detail information can be gained by calling the `--breakdown` argument. Aside from the information above, all subdirectories 1 level below the target directory are listed with status info.
```
$ $fps -r -b

This directory           : Uncomplete

Directories unlisted     : 9  / 29.0%
Directories uncomplete   : 15 / 48.4%
Directories complete     : 7  / 22.6%

Subdirectories breakdown : unListed / Uncomplete / Complete

C : --C : Coding
U : LUC : Desktop
U : -U- : Documents
U : -UC : Downloads
L : --- : Dropbox
```

Each line represents a subdirectory. Single-letter representations of each status are used:
- **L** : Unlisted
- **U** : Uncomplete
- **C** : Complete

The left-most column is the status of the subdirectory, while the second column lists the statuses found within it. Therefore the following can be said of the subdirectories in the example above:
- **Coding** is complete, and only contains complete directories. Your work is done here.
- **Desktop** is marked uncomplete and contains a mixture of unlisted, uncomplete and complete directories. You could change into this directory and run `tf_fp_status.rb -r -b` again to begin finding exactly which directories these are.
- **Documents** is uncomplete and only contains uncomplete directories. Work hasn't started here yet.
- **Dropbox** is unlisted and contains no directories. This is evident as any of its subdirectories has to be in 1 of the 3 statuses.
