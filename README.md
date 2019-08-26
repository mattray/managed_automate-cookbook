# managed_automate

Deploys and configures the Chef Automate 2 server in an airgapped, stateless model.

# Recipes

## default ##

Installs or upgrades Chef Automate on a single airgapped box in a new deployment. The download the `chef-automate` commands before using this recipe (the `airgap_bundle` recipe does this) and copy it to the `node['ma']['aib']['dir']` directory. The AIB or upgrade file may be a URL or a file, similar to this:

    node['ma']['aib']['dir'] = '/tmp
    node['ma']['aib']['file'] = 'automate-20181112131523.aib'

The server will be tuned for passing Automate's `preflight-check` and swap will be disabled and the heapsize for Elasticsearch will be set to 1/2 total memory. The license may be referred as a URL or a string in an attribute. The recipe will attempt to restore if a backup file is specified in the attributes.

## airgap_bundle ##

This recipe requires internet access and is used to download the `chef-automate` CLI and create an airgap installation bundle (AIB file) from the "current" release channel. It copies the downloaded AIB file to a destination directory with both the original filename and a generic filename for consistent installations if desired. It will download a full AIB every run (currently 600 megabytes), so you may want to limit it to daily usage.

## backup

Runs `chef-automate backup` via cron and copies tarballs of the backups to a destination directory. The default is 2:30am daily, but you may change the cron schedule via the following attributes.

    node['ma']['backup']['cron']['minute'] = '30'
    node['ma']['backup']['cron']['hour'] = '2'
    node['ma']['backup']['cron']['day'] = '*'

This will probably get rewritten when the backup gateway is available.

# Testing with Test Kitchen

The included `.kitchen.yml` provides testing scenarios for the following:

  * `default`: tests installing from a previously downloaded `chef-automate` and `chef-automate-airgap.aib` (use the `aib` suite to create this if necessary) to the shared `test` directory.
  * `url`: tests installing from a previously downloaded `chef-automate-airgap.aib` and license via URLs.
  * `backup`: install and configure backups.
  * `restore`: install from a backup .tgz.
  * `aib`: tests creating an airgap bundle for installing Automate offline. It writes `chef-automate` and `chef-automate-airgap.aib` to the shared `test` directory.
  * `full`: performs both the airgap bundle creation and installation.

## .kitchen.yml ##

The `.kitchen.yml` sets the VM to have the private IP `192.168.33.33`. If you want to use the Automate web UI, you will need to get the self-signed certificate created with the installation

  1. Use `knife ssl fetch https://192.168.33.33` to pull the `default-centos-7.vagrantup.com.crt`.
  2. Install the certificate on your workstation. Under MacOS I used the Keychain Access application and did **File->Import Items** and selected the certificate. I then set the permissions to allow everything and deleted it when I destroyed the Vagrant machine.
  3. Connect to https://192.168.33.33 which will redirect to `default-centos-7.vagrantup.com` or one of the other suites. This works with Chrome, not Firefox.

You will probably need to update the license, directories and AIB files used for your testing. To use a license key, store it in your `policyfiles/chef-automate2.rb` similar to this:

```
override['ma']['license']['string'] = 'thisisnotareallicence_dHlwZSI6ImNvbW1lcmNpYWwiLCJnZW5lcmF0b3IiOiJjaGVmL2xpY2Vuc2UtMi4wLjAiLCJrZXlfc2hhMjU2IjoiZTBkZjI4YzhiYzY4MTUwZWRiZmVmOThjZDZiN2RjNDM5YzFmODBjN2U3ZWY3NDc4OTNhNjg5M2EyZjdiNjBmNyIsImdlbmVyYXRpb25fZGF0ZSI6eyJzZWNvbmRzIjoxNTM0MzQ0MjkwfSwiY3VzdG9tZXIiOiJXZXN0cGFjQVUgLSBBdXRvbWF0ZSAtIE5ldyAtIDMwMDAgTm9kZXMiLCJjdXN0b21lcl9pZCI6Ijg4OEU4NUU3LTY2MUEtNEZGQS04MjlFLTNCRTIyREQyNEU4RCIsImN1c3RvbWVyX2lkX3ZlcnNpb24iOiIxIiwiZW50aXRsZW1lbnRzIjpbeyJuYW1lIjoiQ2hlZiBBdXRvbWF0ZSIsIm1lYXN1cmUiOiJub2RlcyIsInN0YXJ0Ijp7InNlY29uZHMiOjE1MzQyOTEyMDB9LCJlbmQiOnsic2Vjb25kcyI6MTU2NDYxNzU5OX19XX0.AMNR0uiRQgLsfi-W4dBQ5K6EH1HUSK_AFPSIXzzkEn1gAiLjgGwfB3L7oxxrihgV8w8U8Vsxeal_CGg5GI99le3FAYYt5wdCG-8VZNScVcyL8xCIdPUyl0ZV-NLjyhLzf5JKrl9E1dTBzMrh__OsNx34TgRLZ-xNKNekUAy9sVdyHryf'```
