
This directory is for constructing installation packages.  So far only .deb is supported. And by "supported" I mean only in the minimal sense. The procedure outlined here will produce a barely adequate .deb file -- on that stands no chance of being accepted let alone praised by the maintainers of any Unix repository. It will only be useable by someone who can upload it and install it via the dpkg command.

To create a .deb package do the following:

1. compile socsim (there's a Makefile for this) 
2. copy the entire socsim\_1.0-1 directory into socsim\_1.0-2  Obviously with the passage of time these release numbers will change
3. copy the newly compiled binary on top of the old socsim\1.0-2/usr/local/bin/socsim
4. Modify the socsisim\_1.0-2/DEBIAN/control file in ways that seem sensible. At the very least the version number must correspond to the name of the new directory.
5. run dpkg-deb --build socsim_1.0-2  to create the .deb package file.


