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
