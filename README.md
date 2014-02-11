DAGMC_CI
=========

This contains the files necessary to run Continuous Integration and Test on batlab.org
The scripts used to submit the run are in github.com/DAGMC-CI, master branch.
The build created will be github.com/DAGMC, whichever branch was the subject of the initiating
pull request on the DAGMC repository.

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
