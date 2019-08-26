# managed-automate2 CHANGELOG

This file is used to list changes made in each version of the managed-automate2 cookbook.

# 0.1.0

- Initial release.
- airgap_bundle downloads aib file
- default recipe installs automate

# 0.2.0

- default recipe configures to pass preflight check

# 0.3.0

- default recipe applies license

# 0.4.0

- relax Chef version to 13 from 14, adding sysctl cookbook

# 0.5.0

- aib as a URL or a file in the default recipe
- license as a URL or a string in the default recipe

# 0.6.0

- Original AIB filename is now preserved in addition to generic name.
- Add support for backup recipe and restoring from a backup file.

# 0.7.0

- refactored install/restore/upgrade logic to manage upgrades

# 0.7.1

- code cleanup and updated tests

# 0.8.0

- added Elasticsearch tuning via the private `_elasticsearch.rb` recipe

# 0.9.0

- move to Chef 14/15 and add testing support
- remove sysctl cookbook dependency

# 0.10.0

- change cookbook name from 'managed-automate2' to 'managed_automate'
  - refactor attributes from 'ma2' to 'ma' namespace
- refactor to Custom Resources
- fix broken backups and restore
- more resilient to nils
- [https://github.com/mattray/managed-automate2-cookbook/issues/9](airgap_bundle safe for multiple runs)
- [https://github.com/mattray/managed-automate2-cookbook/issues/8](wait for completion of upgrade before proceeding)

# BACKLOG
