#
# Makefile for ferm
#

VPATH		= man:info

PREFIX		= /usr
INSTDIR		= $(PREFIX)/sbin
MANDIR		= $(PREFIX)/man/man1
DOCDIR		= $(PREFIX)/doc/packages/ferm
SHELL		= /bin/bash
SRC		= src/ferm
MANSRC		= src/ferm.pod

VERSION := $(shell ${SRC} --version | awk '{print $$2}' | head -1 | tr -d ',')

DISTDIR = build/ferm-$(VERSION)

TARFILE = build/ferm-${VERSION}.tar.gz
LSMFILE	= build/ferm-${VERSION}.lsm

SIZE = $(shell du -h -D $(TARFILE) | awk '{print $$1}')
DATE            = `date '+%Y-%m-%d'`

WEBDIR		= /home/web/users/koka/ferm
FTPDIR		= /home/tecguest/ises/koka/anonftp

all: man

pub:	www ftp

.phony:

manobjects = ferm.txt ferm.html man/ferm.1
tmpfiles = pod2html-dircache pod2html-itemcache 'pod2htmd.x~~' 'pod2htmsid.x~~' 'pod2htmi.x~~'

$(manobjects): $(MANSRC)

man:	$(manobjects)

clean:
	@rm -f man/ferm.* $(tmpfiles) *.tar.gz
	$(MAKE) -C test $@

#
# test suite
#

.PHONY: check
check:
	$(MAKE) -C test $@

#
# compiling targets
#

man/ferm.1: src/ferm.pod
	pod2man --section=1 --release="ferm $(VERSION)" \
		--center="FIREWALL RULES MADE EASY" \
		--official $< > $@

man/ferm.html: src/ferm.pod
	pod2html $< --netscape --flush > $@

man/ferm.txt: src/ferm.pod
	pod2text $< > $@

build/ferm-$(VERSION).tar.gz: all
	rm -rf $(DISTDIR)
	install -d -m 755 build $(DISTDIR) $(DISTDIR)/doc $(DISTDIR)/examples
	install -m 755 src/ferm $(DISTDIR)
	install -m 644 scripts/Makefile info/AUTHORS info/CHANGES info/COPYING info/README info/TODO $(DISTDIR)
	install -m 644 man/ferm.1 man/ferm.html man/ferm.txt $(DISTDIR)/doc
	install -m 644 examples/complex-server examples/iptables examples/realistic examples/workstation examples/iptables-newbie examples/tjzeeman $(DISTDIR)/examples
	cd build && tar czf ferm-$(VERSION).tar.gz ferm-$(VERSION)

dist: build/ferm-$(VERSION).tar.gz

#
# misc targets
#

install uninstall: dist
	make -C $(DISTDIR) $@

www:	tar
	@echo "Publishing tarfiles in $(WEBDIR)..."
	@rm -f $(WEBDIR)/ferm.tar.gz
	@cp $(TARFILE) $(WEBDIR)
	@cp info/CHANGES $(WEBDIR)
	@cp man/ferm.html $(WEBDIR)
	@echo $(VERSION) > $(WEBDIR)/VERSION
	@ln -s $(TARFILE) $(WEBDIR)/ferm.tar.gz
	@chmod ugo+r $(WEBDIR)/$(TARFILE) $(WEBDIR)/ferm.tar.gz \
		$(WEBDIR)/CHANGES $(WEBDIR)/VERSION $(WEBDIR)/ferm.html
	@echo "Done."

ftp:	tar
	@echo "Publishing tarfiles in $(FTPDIR)..."
	@rm -f $(FTPDIR)/ferm.tar.gz
	@cp $(TARFILE) $(FTPDIR)
	@cp info/CHANGES $(FTPDIR)
	@echo $(VERSION) > $(FTPDIR)/VERSION
	@ln -s $(TARFILE) $(FTPDIR)/ferm.tar.gz
	@chmod ugo+r $(FTPDIR)/$(TARFILE) $(FTPDIR)/ferm.tar.gz \
		$(FTPDIR)/CHANGES $(FTPDIR)/VERSION
	@echo "Done."

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
