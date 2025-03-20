# configuration-manager
Started as a collection of scripts

## Installation and dependencies

You need a shell, git and awk
```sh
git clone https://github.com/plagache/configuration-manager
cd configuration-manager
./configuration-manager
```

## Objectives
so i have different configuration with mac and linux and my idea at first was to create a simple tools to manage all my config,
I only have acccess to base language, available on any mac or linux, so i choose AWK to parse my csv and sh to create the final script for the user
sometimes i do not have privilages
so i did a program with some multiple #!/bin/sh script and awk to parse my csv of packages, and csv of command per package manager, and create a profile in a csv with the package manager i want and there tags
Select/Create Profile base on tags (minimal,dev,desktop) available in packages.csv
Create/build script to install;update;clean packages;services;Files
what do you think of this methode ?
how can i improve it with the configuration of linux services?
