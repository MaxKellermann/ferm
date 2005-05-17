#
# Makefile for ferm
#

TOPDIR = .
include $(TOPDIR)/config.mk

VERSION := $(shell perl src/ferm --version | awk '{print $$2}' | head -1 | tr -d ',')

DISTDIR = build/ferm-$(VERSION)

TARFILE = build/ferm-${VERSION}.tar.gz
LSMFILE	= build/ferm-${VERSION}.lsm

.PHONY: all clean check

all:
	make -C doc $@

clean:
	rm -rf build
	make -C doc $@
	make -C test $@

check:
	make -C test $@

#
# distribution
#

build/ferm-$(VERSION).tar.gz: all
	rm -rf $(DISTDIR)
	install -d -m 755 $(DISTDIR) $(DISTDIR)/src $(DISTDIR)/doc $(DISTDIR)/examples
	install -m 755 src/ferm $(DISTDIR)/src
	install -m 644 doc/Makefile doc/ferm.pod doc/ferm.txt doc/ferm.html doc/ferm.1 $(DISTDIR)/doc
	install -m 644 config.mk Makefile AUTHORS COPYING NEWS README TODO $(DISTDIR)
	install -m 644 $(wildcard examples/*.ferm) $(DISTDIR)/examples
	cd build && tar czf ferm-$(VERSION).tar.gz ferm-$(VERSION)

dist: build/ferm-$(VERSION).tar.gz

#
# installation
#

.PHONY: install uninstall

install: all
	install -d -m 755 $(DOCDIR)/examples $(PREFIX)/sbin
	install -m 644 AUTHORS COPYING NEWS README TODO $(DOCDIR)
	install -m 644 examples/* $(DOCDIR)/examples
	install -m 755 src/ferm $(PREFIX)/sbin/ferm
	make -C doc $@ PREFIX=$(PREFIX)

uninstall:
	rm -rf $(DOCDIR)
	rm -f $(MANDIR)/ferm.1 $(MANDIR)/ferm.1.gz
	rm -f $(PREFIX)/sbin/ferm
	make -C doc $@ PREFIX=$(PREFIX)

#
# misc targets
#

www: dist
	@echo "Publishing tarfiles in $(WEBDIR)..."
	rm -f $(WEBDIR)/$(notdir $(TARFILE))
	cp $(TARFILE) $(WEBDIR)
	cp NEWS $(WEBDIR)
	cp doc/ferm.html $(WEBDIR)
	echo $(VERSION) > $(WEBDIR)/VERSION
	ln -s $(notdir $(TARFILE)) $(WEBDIR)/ferm.tar.gz
	chmod ugo+r $(WEBDIR)/$(notdir $(TARFILE)) $(WEBDIR)/ferm.tar.gz \
		$(WEBDIR)/NEWS $(WEBDIR)/VERSION $(WEBDIR)/ferm.html
	@echo "Done."

ftp: dist
	@echo "Publishing tarfiles in $(FTPDIR)..."
	rm -f $(FTPDIR)/$(notdir $(TARFILE))
	cp $(TARFILE) $(FTPDIR)
	cp NEWS $(FTPDIR)
	echo $(VERSION) > $(FTPDIR)/VERSION
	ln -s $(notdir $(TARFILE)) $(FTPDIR)/ferm.tar.gz
	chmod ugo+r $(FTPDIR)/$(notdir $(TARFILE)) $(FTPDIR)/ferm.tar.gz \
		$(FTPDIR)/NEWS $(FTPDIR)/VERSION
	@echo "Done."

pub: www ftp

$(LSMFILE): DATE = `date '+%Y-%m-%d'`
$(LSMFILE): SIZE = $(shell du -h -D $(TARFILE) | awk '{print $$1}')
$(LSMFILE): dist
	@echo "Making lsm entry file..."
	@echo "Begin4" > $@
	@echo "Title:          ferm" >> $@
	@echo "Version:        $(VERSION)" >> $@
	@echo "Entered-date:   $(DATE)" >> $@
	@echo "Description:    A tool for structured firewall-rule making" >> $@
	@echo "Keywords:       iptables ipchains ipfwadm firewall rules rule" >> $@
	@echo "Author:         sofar@foo-projects.org (A. Kok)" >> $@
	@echo "Maintained-by:  sofar@foo-projects.org (A. Kok)" >> $@
	@echo "Primary-site:   ferm.foo-projects.org /" >> $@
	@echo "                $(SIZE) $(TARFILE)" >> $@
	@echo "Alternate-site:" >> $@
	@echo "Original-site:" >> $@
	@echo "Platforms:      perl linux>=2.4" >> $@
	@echo "Copying-policy: GPL" >> $@
	@echo "End" >> $@
# @echo "Sending lsm entry..."
# @mailx -s "add" lsm@execpc.com < $@
	@echo "Done."

.phony: lsm
lsm: $(LSMFILE)
