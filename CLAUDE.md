@../_shared/apps.md

## This project
- For the Finder/iTerm toolbar apps: `build.sh` reapplies the Finder icons itself. A rebuilt app has a new ad-hoc signature, so the copies in `/Applications` must be replaced and macOS will re-ask for Automation permission on first click. Say so after any rebuild.
