DAGMC_CI
=========

This contains the files necessary to run Continuous Integration on batlab.org

GIT Repository
_______________

This git repository lives on github.com/svalinn and is owned by the dagmcci group.  

If this git repository is cloned via https you will be unable to push to github.
Instead, this repository should be cloned via ssh (after adding your public ssh key to the git repository). 

Submitting a job
________________
This repo is intended to be run by a software robot on the dagmcci login of subit-1.batlab.org.  The
scripts are pulled from the repository and placed in a directory with a newly constructed name.  As
such, the file copying must not reference a particular directory structure.  Since the *.scp scripts
are designed to reference with respect to the local subdirectory under $HOME, they will not work as
intended.  The submit.sh script is a simple workaround to this problem.  On the run node, the 
submit.sh script pulls the name of the directory from the run node side and uses it to write out the .scp
files on the fly so they will be correct with respect to the robotically constructed name.

If you are running from your own private batlab login, the job should be submitted by typing:
$ ./submit.sh fludag.run-spec    // RIGHT
and not 
$ ./nmi_submit fludag.run-spec   // WRONG

Removing CRON jobs from BaTLab
_____________________________
Note:  See the Command Line Tools in the online BaTLab Reference Manual

$ nmi_list_recurring_runs
	-- get the recurring run id of the job you want to kill
	-- should end in .0
$ nmi_rm <recurring run id>
$ nmi_submit recurring_job.run-spec
