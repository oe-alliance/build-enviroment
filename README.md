build-enviroment
================

This sets-up the oe-alliance build environment.

building on newer host systems
==============================

If you want to build this EOL branch on newer host systems, e.g. Ubuntu 18.04,
you have to perform some additional steps after the very FIRST "make update":

patch -p1 < ./fix-openembedded-core-gcc8-mimimi.patch
patch -p1 < ./fix-shitquake-git-and-svn-fetch.patch
cd ./meta-oe-alliance/
git pull origin 3.4
cd ..

