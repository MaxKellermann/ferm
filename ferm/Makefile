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

VERSION         = `${SRC} --version | awk '{print $$2}' | head -1 | tr -d ','`

TARDIR		= ferm-${VERSION}
TARFILE		= ferm-${VERSION}.tar.gz
LSMFILE		= lsm/ferm-${VERSION}.lsm

SIZE            = `du -h -D ferm.tar.gz | awk '{print $$1}'`
DATE            = `date '+%Y-%m-%d'`

WEBDIR		= /home/web/users/koka/ferm
FTPDIR		= /home/tecguest/ises/koka/anonftp

all:	man tar

pub:	www ftp

.phony:

manobjects = ferm.txt ferm.html ferm.1
tarobjects = ferm.tar.gz
tmpfiles = pod2html-dircache pod2html-itemcache 'pod2htmd.x~~' 'pod2htmsid.x~~' 'pod2htmi.x~~'

$(manobjects): $(MANSRC)
$(tarobjects): $(MANSRC) $(SRC)

man:	$(manobjects)
tar:	man $(tarobjects)

clean:
	@rm -f man/ferm.* $(tmpfiles) $(tarobjects)
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

ferm.1:
	@echo "Making unix manual page..."
	@pod2man --section=1 --release="ferm $(VERSION)" \
		--center="FIREWALL RULES MADE EASY" \
		--official $(MANSRC) > man/ferm.1

ferm.html:
	@echo "Making HTML manual page..."
	@pod2html $(MANSRC) --netscape --flush > man/ferm.html
	@rm -f $(tmpfiles)

ferm.txt:
	@echo "Making plain text manual page..."
	@pod2text $(MANSRC) > man/ferm.txt

ferm.tar.gz:
	@rm -rf $(TARDIR)
	@mkdir $(TARDIR)
	@mkdir $(TARDIR)/examples
	@echo "Gathering files in ferm-$(VERSION)/..."
	@cp $(SRC) $(TARDIR)
	@cp $(MANSRC) $(TARDIR)
	@cp scripts/Makefile $(TARDIR)
	@cp man/ferm.* $(TARDIR)
	@cp info/AUTHORS info/CHANGES info/COPYING info/README info/TODO $(TARDIR)
	@cp examples/complex-server examples/iptables examples/realistic examples/workstation examples/iptables-newbie examples/tjzeeman $(TARDIR)/examples
	@echo "Making tar file..."
	@tar cf $(TARDIR).tar $(TARDIR)
	@gzip -f $(TARDIR).tar
	@rm -rf $(TARDIR)
	@echo "Done."

#
# misc targets
#

install:
	@cd $(TARDIR) && make install

uninstall:
	@cd $(TARDIR) && make uninstall

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

lsm: .phony
	@echo "Making lsm entry file..."
	@echo "Begin4" > ${LSMFILE}
	@echo "Title:          ferm" >> ${LSMFILE}
	@echo "Version:        $(VERSION)" >> ${LSMFILE}
	@echo "Entered-date:   $(DATE)" >> ${LSMFILE}
	@echo "Description:    A tool for structured firewall-rule making" >> ${LSMFILE}
	@echo "Keywords:       iptables ipchains ipfwadm firewall rules rule" >> ${LSMFILE}
	@echo "Author:         sofar@foo-projects.org (A. Kok)" >> ${LSMFILE}
	@echo "Maintained-by:  sofar@foo-projects.org (A. Kok)" >> ${LSMFILE}
	@echo "Primary-site:   ferm.sourceforge.net /" >> ${LSMFILE}
	@echo "                $(SIZE) ferm.tar.gz" >> ${LSMFILE}
	@echo "Alternate-site:" >> ${LSMFILE}
	@echo "Original-site:" >> ${LSMFILE}
	@echo "Platforms:      perl linux>=2.0" >> ${LSMFILE}
	@echo "Copying-policy: GPL" >> ${LSMFILE}
	@echo "End" >> ${LSMFILE}
	@echo "Sending lsm entry..."
        # @mailx -s "add" lsm@execpc.com < ${LSMFILE}
	@echo "Done."

