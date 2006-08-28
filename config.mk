PERL = /usr/bin/perl

PREFIX = /usr
MANDIR = $(PREFIX)/man/man1
DOCDIR = $(PREFIX)/share/doc/ferm

WEBDIR = /home/web/users/koka/ferm
FTPDIR = /home/tecguest/ises/koka/anonftp

# location of the old ferm script, for the test suite
OLD_FERM = $(TOPDIR)/test/ferm1.1
OLD_OPTIONS = --use iptables --lines --noexec --clearall --flushall --createchains

NEW_FERM = $(TOPDIR)/src/ferm
NEW_OPTIONS = --test
