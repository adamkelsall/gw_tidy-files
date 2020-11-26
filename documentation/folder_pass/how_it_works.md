# How It Works

## Directory Statuses

For the purposes of Folder Pass, all directories are considered to be in 1 of 3 states:

- **Unlisted** - Not part of the directories persistent file.
- **Uncomplete** (0) - Added to the directories persistent file but not completed with `tf_fp_complete.rb`
- **Complete** (1) - Added to the directories persistent file *and* completed with `tf_fp_complete.rb`

## Add / Complete Logic

The following rules apply when adding and completing directories:

| Script   | Dir. Status | Logic |
| -------- | ----------- | ----- |
| Add      | Unlisted    | Added with status uncomplete |
| Add      | Uncomplete  | *Nothing* |
| Add      | Complete    | Resets status to uncomplete |
| Complete | Unlisted    | *Nothing* |
| Complete | Uncomplete  | Directory marked as complete |
| Complete | *Deleted*   | Directory marked as complete |
| Complete | Complete    | *Nothing* |

As seen above, `tf_fp_add.rb` resets complete directories back to uncompleted, and `tf_fp_complete.rb` does not do anything to unlisted directories, they must be tracked first.

## Persistent Data

Folder pass creates a persistent folder at `folder_pass/persistent` which is used to store the list of tracked directories, blacklist and logs. This directory is ignored by git and created as needed on execution.

### Directories

File: `folder_pass/persistent/directories`

When new directories are added with the `tf_fp_add.rb` script, they are added into the directories file and marked as uncomplete. Below is an example of this file's contents:

```
0 c:/Users/example/Documents/directory
1 c:/Users/example/Documents/directory/subdirectory
```

Each line is a directory and is prefixed with `0` or `1` to represent uncomplete and complete respectively.

### Blacklist

File: `folder_pass/persistent/blacklist`

As with other GW Ruby projects, the blacklist file is a list of line-separated regular expressions that recursive directory functions will ignore matches against.

For example `/\.git$/` will ignore all directory paths ending in .git, and prevents subdirectories of .git folders from being listed too.

When this file is created the executing script will exit, allowing the you time to add additional regular expressions if needed. By default the expression `/\/\.{1,2}$/` is added to prevent the script from getting stuck in a loop.

### Logs

Directory: `folder_pass/persistent/logs`

All logs are CSV formatted. Whenever a log file is created during execution, the script will output a line including the path to the new log CSV.

#### Daily Logs

Whenever one or more directory status updates are made in a day, a new daily log CSV is created.

An example of the data stored in a daily log CSV. Not that status totals are included in each line:

```
Timestamp,Action,Total,Complete,Uncomplete,Directory
1405068112,add,1,0,1,"c:/Users/example/Documents/directory"
```

#### Summary Log

Every time a new daily log is created, the status totals from the last line of the previous daily log are written to the summary log CSV. This provides one row of data per day and allows for lower resolution data on your folder pass over time. Example rows:

```
Date,Total,Complete,Uncomplete
2014-07-10,1,1,0
```
