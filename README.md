DAGMC_CI
=========

This repo contains files necessary to run Continuous Integration and Test on batlab.org.
There are two types of build-and-test:

1.  Pull-generated build-and-test

When a developer generates a pull request from a feature branch to the develop branch 
on github.com/DAGMC ('DAGMC') a one-off batlab build-and-test is executed using the
feature branch.

The pull-generated build-and-test ensures that developers do not check in code that has
deleterious side effects.  These tests are auto-generated and designed to runfrom the 
dagmcci@submit-1.batlab.org login.

> ./submit fludag.run-spec
 
2.  Nightly build-and-test

Nightly builds are setup manually and launched from an individual batlab account.
The build created will be the github.com/DAGMC develop branch.

The nightly build-and-test ensures that software dependencies and third party updates
have not broken FluDAG.

It is launched from the cloned DAGMC-CI repository with
> ./submit_nightly.sh fludag_nightly.run-spec

GIT Repository
_______________

The DAGMC-CI git repository lives on github.com/svalinn and is owned by the dagmcci group.  

If this git repository is cloned via https you will be unable to push to github.
Instead, this repository should be cloned via ssh (after adding your public ssh key to the git repository). 

Submitting a job
________________
DAGMC-CI is intended to be run by a software robot, 'Polyphemer', on the dagmcci login of 
submit-1.batlab.org.  The scripts are pulled from the repository and placed in a directory 
with a newly constructed name.  As such, the file copying must not reference a particular 
directory structure under $HOME.  Since the *.scp scripts must reference 
the repository subdirectory under $HOME, they will not work as intended in a $HOME substructure 
that differs from the repo.  The submit.sh script is a simple workaround to this problem.  

On the run node, the submit.sh script pulls the name of the directory from the run node side 
and uses it to write out the .scp files on the fly so the current path appended to the front 
will be correct with respect to the name constructed by Polyphemer.

If you are testing scripts and want to run from your own private batlab login, the job should 
be submitted by typing:

$ ./submit.sh fludag.run-spec    // RIGHT

and not 

$ ./nmi_submit fludag.run-spec   // WRONG

Initiating a job
________________
Polyphemer executes the scripts on dagmcci:batlab when a pull request is made on a DAGMC branch.
The branch in question will be checked out and cloned to the submit node.  NOTE:  the script file
in the fetch subdirectory named 'dagmc.git' specifically checks out the 'develop' branch, however this
is not what happens on the submit node.  'develop' is replaced by the branch against which the pull
request was made.


Removing CRON jobs from BaTLab
_____________________________
Note:  See the Command Line Tools in the online BaTLab Reference Manual

$ nmi_list_recurring_runs

	-- get the recurring run id of the job you want to kill
	-- should end in .0

$ nmi_rm <recurring run id>

$ nmi_submit recurring_job.run-spec

Setting up Git
_____________

Place the following lines in the home directory in a file called '.gitconfig':


[user]
	name = dagmcci
	email = dagmcci@googlegroups.com
[alias]
	co = checkout
	st = status
	plog = log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s%Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --graph --decorate --date=relative

