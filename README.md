# configuration-manager
Started as a collection of scripts

## Installation and dependencies

You need git and awk
```sh
git clone https://github.com/plagache/configuration-manager
cd configuration-manager
./configuration-manager
```

## Objectives

Multiple sessions / different usage:

Check if there is a session, default to USER name, can be provided

- create session config
    - list and allow selection of available sources, interfaces, and context
    - how to define important context? e.g. with the sound interface, what is the difference between a driver and a required dependencies of a programs? how to show the relation between a dependencies its program?
    - if there was no argument for the session creation it takes the USER name has name
    - test session config can work on system and session

if a session with the given name exist display the config

Check if the build for given name exist

Multiple package manager / sources:
- test if session is configured for the current user
- build session
    - create script install;update;clean
    - post install action ? services to enable ? Other Config file to add, e.g. kanata config file (script that check and replace already exist) ?
    - 2 type of things to do, install something, configure
    - packages not in the list of data with special install Neovim, nextcloud
- detect change from session / and packages
- diff when rebuilding a session between tmp and newly created

Check if the build/scripts are in the Active directory

if every thing has been checked prompt with diff between currently installed and scripts in active dir

## limitations

sometimes i do not have privilages
access to base tool, language, available on any mac or linux
- AWK to parse data, #!/bin/sh
- do we need to separate the data ? packages.csv in different source?
