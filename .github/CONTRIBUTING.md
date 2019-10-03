# Contributing to PsPM
Thank you for contributing to PsPM! Below we describe the main points that you need to know before you can start contributing
new features to PsPM. In addition we present some guidelines regarding bug reports and help, feature, pull requests and more.

---

#### Table of Contents
[Need Help?](#need-help)

[How Can I Contribute?](#how-can-i-contribute)
* [Bug Reports](#bug-reports)
* [Feature Requests](#feature-requests)
* [Pull Requests](#pull-requests)

[Development Model and Git Flow](#development-model-and-git-flow)
* [Branches](#branches)
* [Issues](#issues)
* [Pull Request](#pull-requests)

[Documentation](#documentation)

---

## Need Help?
If you need help regarding the usage of PsPM, please [open a new issue](https://github.com/bachlab/PsPM/issues/new/choose) under
**Help Request** category. Here you can ask both general and specific questions regarding PsPM. Also check out the labels on the
right after you have finished typing your question; if you feel like some of the labels fit into your case, please choose them since
this makes it easier for us to assign your question to a developer. After we receive your request, we will try to respond as
quickly as we can.

## How Can I Contribute?
If you want to report a bug, fix a bug or contribute a completely new feature, you are all but welcome. Before starting, please read
the below items and also the [Development Model and Git Flow](#development-model-and-git-flow) section to get an idea about how
PsPM is developed.

### Bug Reports
If you have spotted a bug in PsPM, please [open a new issue](https://github.com/bachlab/PsPM/issues/new/choose) under **Bug Report**
category. Here you should fill the given sections and give us as much information about the bug as possible. If you feel like
you need a separate section in order to describe some aspect of the bug, just add that section to the bug report. Further, please
choose the appropriate labels for your bug report so that we can categorize the issue more quickly, and respond faster.
https://semver.org/
### Feature Requests
If you think that PsPM is missing some feature, please [open a new issue](https://github.com/bachlab/PsPM/issues/new/choose)
under **Feature Request** category. Please describe the feature as best as you can and possibly include as much details as possible.

### Pull Requests
You can request to include your contributions to PsPM by creating a pull request. However, we recommend that you first create a
new issue to describe your contributions before doing the actual work. This way, we can discuss the various possible implementation
details before you make the effort, and maximize the development efficiency.

If you are not a core PsPM developer, by default you don't have access rights to create a branch in PsPM repository.
Therefore, in order to implement your ideas, you need to follow the below procedure:

1. Fork PsPM repository under your account
2. Implement your feature under this new repository in some branch. You can implement the feature directly in **develop** branch
or you can create a feature branch.
3. After you are finished, create a pull request from your forked repository into github.com/bachlab/PsPM develop branch.

After these three steps are completed, we will see your proposed changes. 

In the pull request, please explain your proposed changes in detail, and also reference the issue that your
pull request adresses, if such an issue exists.

A pull request should not be too long. Sometimes thousands of lines long pull requests are necessary due to the nature of the
proposed changes, but these type of pull requests should not be common. Small, easy-to-review pull requests are preferred.

## Development Model and Git Flow
This section is intended for core PsPM developers. Here we describe the git flow used during PsPM development:

### Branches
**master** is the branch for stable version of PsPM. It is protected by default and does not allow direct pushes. Rather, an approved
pull request is required to commit any code to master.

**develop** is the branch for development version of PsPM. It is not protected; however, **pushing directly to develop branch is
discouraged**. Rather, please group your commits that are related to some feature, bug fix, etc. and create a pull request. This
is a natural way to document the commit history and allows easier repository browsing.

Any other branch is used for bug fixes, new features, changes, etc. Apart from **master** and **develop** there shouldn't be a
long-running branch in the repository, i.e. don't create a branch and implement 100 commits worth of stuff before creating a pull
request. Also note that other branches are not protected in any way; therefore ammending the commits, rebasing and force pushing
into these topic branches are not discouraged, as they allow to keep the commit history cleaner.

Topic branches (any branch other than master or develop) should only be merged into develop, and not into master. When a new
release is going to be made, develop branch should be merged into master and a tag in master branch should be created. In addition,
topic branches should be deleted after are merged into develop branch to keep the repository tidied up and easier to browse.

### Issues
Please use the issue system to create new tasks with **TODO** label. Every time you create an issue, please go through all the
labels and pick all the labels that fit into the current issue. Further, assign the issues to milestones. PsPM versioning follows
[semver](https://semver.org/). Therefore,

1. If your issue is a bugfix, a small change or something similar that is **backwards compatible**, then assign the issue to
milestone with the higher PATCH version.
2. If you have a new feature or functionality that can be implemented in a **backwards compatible** manner, then assign the
issue to milestone with the higher MINOR version.
3. If you are proposing **backwards incompatible** API changes, then assign the issue to milestone with the higher MAJOR version.


## Documentation
If you implement a change that requires modification in function documentation, you need to change more than one place in the
current version of PsPM. We are in the process of improving this, but for now any contributor should be aware of this point.

1. Updating function documentation at the top of the file. This step is mandatory for all functions.
2. If the function you modify is a user-level function in matlabbatch, you need to update matlabbatch documentation so that it is
visible in PsPM GUI. You can check if the function is a user-level function in matlabbatch by searching **src/pspm_cfg** directory
for it and checking the corresponding **pspm_cfg_** and **pspm_cfg_run_** files.
3. If the function you modify is also documented in PsPM Manual (**doc/PsPM_Manual.lyx**), you need to update the manual, as well.

