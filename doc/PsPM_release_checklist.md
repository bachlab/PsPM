# PsPM Release Checklist
This file contains the steps required before finalizing a PsPM release. Many items at the
beginning don't have to be followed sequentially. However, it is important that there aren't
any revisions (commits) that implement/fix something new in the release branch, because we
don't merge these branches back to trunk. Therefore, it is sensible to create the
release branch after making absolutely sure that no new stuff will be implemented.

- [x] Update version number & date in
  - [x] `pspm_msg`
  - [x] `pspm_quit`
  - [x] `pspm.fig`: Load `pspm.fig` into MATLAB, update `fig.Children(9).String` and save back to `pspm.fig`
  - [x] Manual and Developers Guide: front pages
- [x] Make sure both manuals are updated
- [x] Add release notes section of the new version to manual (at the end) and release_notes.tex
- [x] Get the manual reviewed
- [x] Create manual and dev guide PDFs using `lyx`
- [x] Check if underscores and dashes are visible in newly added manual sections
- [x] Create git branch
- [x] Delete `.asv` files if there are any (?)
- [x] Create zip of the new branch
- [x] Make sure zip doesn't contain any svn related files. As a sanity check, the zip file
should be roughly the same size as the previous version zip files (maybe slightly larger but not much)
- [ ] Create a release on GitHub
- [ ] Upload zip to GitHub
  - [ ] Make sure the newly added zip file is the default download
- [ ] Add release message to GitHub
- [ ] Change release number on lab webpage (gh-pages branch)
- [ ] Add release message to lab webpage (gh-pages branch)
