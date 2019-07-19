# Code Style

## Whitespace conventions in the BETYdb Code

We want to avoid introducing extraneous whitespace into our source files.  There are two kinds of extraneous whitespace that you generally won't see in your editor:

1. Extra whitespace at the end of a line ("trailing whitespace")
1. Tab characters

I call tab characters "extraneous whitespace" because if your editor shows tab characters as 4 spaces and my editor shows them as 8 spaces, I'm going to see a lot more whitespace than you are seeing, and the code alignment is going to look all wrong.

In general, please do not use tabs in any Ruby code.  (But if there are tabs already in the file before you start editing it, it may be best to leave them alone.  See below.)

Git has a built-in easy way to check your files for extraneous space before you commit them.  Run the command:

    git diff --check

If you've already staged the files you are about to commit, run

    git diff --cached --check

These commands will find all trailing space and all tab characters that are preceded by a space characters.  To catch other tab characters in your indentation, you will have to update your git configuration by running

    git config --add core.whitespace tab-in-indent

Please do this!  We don't want any tab characters at all in the source files! (One possible exception: It is OK to have tab characters inside of a string literal.)

You can also check for extraneous whitespace that you may have already committed.  To check for extraneous whitespace in your last commit, run

    git diff --check HEAD^

In general, to check for extraneous whitespace commit since commit xyzabc, run

    git diff --check xyzabc

You can combine this with the `git merge-base` command to find all of the whitespace you introduced since branching off of upstream/master:

    git diff --check $(git merge-base HEAD upstream/master)

(If you local copy of master mirrors upstream/master, you can just use "master" in place of "upstream/master" here.)

If you created your branch off your local master branch and haven't changed your local master branch since then, you can just run

    git diff --check master

Please always run some version of the "git diff --check" command before you submit a pull request!

## Fixing legacy formatting

Often when I'm coding, I'm tempted to "fix" the formatting of a file I'm working on.  It's generally easier to understand the code I'm working on if it is nicely indented to show the logical structure.  But there is a drawback to reformatting code: If I want to run "git diff" to find out about the history of a file, I'm going to see a lot of differences I don't care about if the file has been reformatted.  And if I re-indent each line, commit the changes, and then run "git blame", it's going to look as though I am responsible for the latest change on each line.

So here are my recommendations:

* If you have to work extensively with a file, and reformatting it will help you to understand the code better, then go ahead and reformat it.  But if you do this, please:
  * Look up and follow Rails code formatting guidelines (e.g., 2-space indentation levels, etc.)
  * Devote a single commit to just reformatting--don't include any "significant" code changes in that commit.  This will make it easier to figure out the history of a file and what significant code changes were made to it.
* If you are only making minor changes to a file and don't need to reformat the file to figure out what you are doing, just leave the existing formatting alone.  Any new code you add, however, should follow good formatting conventions to the extent possible given that it may be surrounded by poorly-formatted code.
