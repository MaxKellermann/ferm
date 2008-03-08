#
# Makefile for ferm
#

TOPDIR = .
include $(TOPDIR)/config.mk

VERSION := $(shell $(PERL) src/ferm --version | awk '{print $$2}' | head -1 | tr -d ',')

DISTDIR = build/ferm-$(VERSION)

TARFILE = build/ferm-${VERSION}.tar.gz
LSMFILE	= build/ferm-${VERSION}.lsm

.PHONY: all clean

all: doc/ferm.txt doc/ferm.html doc/ferm.1 doc/import-ferm.1

clean:
	rm -rf build
	rm -f doc/ferm.txt doc/ferm.html doc/{import-,}ferm.1 *.tmp

#
# documentation
#

doc/ferm.txt: doc/ferm.pod
	pod2text $< > $@

doc/ferm.html: doc/ferm.pod
	pod2html $< --netscape --flush > $@

doc/ferm.1: doc/ferm.pod
	pod2man --section=1 --release="ferm $(VERSION)" \
		--center="FIREWALL RULES MADE EASY" \
		--official $< > $@

doc/import-ferm.1: src/import-ferm
	pod2man --section=1 --release="ferm $(VERSION)" \
		--center="FIREWALL RULES MADE EASY" \
		--official $< > $@

#
# test suite
#

STAMPDIR = $(TOPDIR)/build/test
STAMPDIR_20 = $(TOPDIR)/build/test2

# a list of all ferm scripts which should be tested with iptables
FERM_SCRIPTS =
FERM_SCRIPTS += $(wildcard test/modules/*.ferm) $(wildcard test/targets/*.ferm)
FERM_SCRIPTS += $(wildcard test/protocols/*.ferm) $(wildcard test/misc/*.ferm)
FERM_SCRIPTS += $(wildcard test/ipv6/*.ferm)
FERM_SCRIPTS += $(wildcard test/arptables/*.ferm) $(wildcard test/ebtables/*.ferm)

EXCLUDE_IMPORT = test/misc/subchain-domains.ferm
IMPORT_SCRIPTS = $(filter-out $(EXCLUDE_IMPORT) test/arptables/% test/ebtables/%,$(FERM_SCRIPTS))

# just a hack
RESULT_SED += -e 's,--protocol tcp --match tcp,-p tcp,g'
RESULT_SED += -e 's,--protocol udp --match udp,-p udp,g'
RESULT_SED += -e 's,-p tcp -m tcp,-p tcp,g'
RESULT_SED += -e 's,-p udp -m udp,-p udp,g'
RESULT_SED += -e 's,--protocol,-p,g'
RESULT_SED += -e 's,--in-interface,-i,g'
RESULT_SED += -e 's,--out-interface,-o,g'
RESULT_SED += -e 's,--destination ,-d ,g'
RESULT_SED += -e 's,--source ,-s ,g'
RESULT_SED += -e 's,--match,-m,g'
RESULT_SED += -e 's,--jump,-j,g'
RESULT_SED += -e 's,--goto,-g,g'
RESULT_SED += -e 's,--fragment,-f,g'

EB_ARP_RESULT_SED = -e 's,--jump,-j,g'

$(STAMPDIR)/test/arptables/%.result: test/arptables/%.ferm $(NEW_FERM)
	@mkdir -p $(dir $@)
	$(PERL) $(NEW_FERM) $(NEW_OPTIONS) $< |sed $(EB_ARP_RESULT_SED) >$@

$(STAMPDIR)/test/ebtables/%.result: test/ebtables/%.ferm $(NEW_FERM)
	@mkdir -p $(dir $@)
	$(PERL) $(NEW_FERM) $(NEW_OPTIONS) $< |sed $(EB_ARP_RESULT_SED) >$@

$(STAMPDIR)/%.result: %.ferm $(NEW_FERM)
	@mkdir -p $(dir $@)
	$(PERL) $(NEW_FERM) --noflush $(NEW_OPTIONS) $< |sed $(RESULT_SED) >$@

$(STAMPDIR)/%.SAVE: %.ferm $(NEW_FERM)
	@mkdir -p $(dir $@)
	$(PERL) $(NEW_FERM) $(NEW_OPTIONS) --fast $< >$@.tmp
	grep -v '^#' <$@.tmp >$@

$(STAMPDIR)/test/ipv6/%.IMPORT: export FERM_DOMAIN=ip6
$(STAMPDIR)/%.IMPORT: $(STAMPDIR)/%.SAVE src/import-ferm
	$(PERL) src/import-ferm $< >$@

$(STAMPDIR)/%.SAVE2: $(STAMPDIR)/%.IMPORT $(NEW_FERM)
	$(PERL) $(NEW_FERM) $(NEW_OPTIONS) --fast $< |grep -v '^#' >$@

$(STAMPDIR)/%.check: %.result $(STAMPDIR)/%.result
	diff -u $^
	@touch $@

$(STAMPDIR)/%.check-import: $(STAMPDIR)/%.SAVE $(STAMPDIR)/%.SAVE2
	diff -u $^
	@touch $@

.PHONY : check-ferm check-import check

check-ferm: $(patsubst %.ferm,$(STAMPDIR)/%.check,$(FERM_SCRIPTS))

check-import: $(patsubst %.ferm,$(STAMPDIR)/%.check-import,$(IMPORT_SCRIPTS))

check: check-ferm check-import

#
# distribution
#

.PHONY: dist

build/ferm-$(VERSION).tar.gz: all
	rm -rf $(DISTDIR)
	install -d -m 755 $(DISTDIR) $(DISTDIR)/src $(DISTDIR)/doc $(DISTDIR)/examples
	install -m 755 src/{import-,}ferm $(DISTDIR)/src
	install -m 644 doc/ferm.pod doc/ferm.txt doc/ferm.html doc/{import-,}ferm.1 $(DISTDIR)/doc
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
	install -m 644 examples/*.ferm $(DOCDIR)/examples
	install -m 755 src/{import-,}ferm $(PREFIX)/sbin/

	install -d -m 755 $(DOCDIR) $(MANDIR)
	install -m 644 doc/ferm.txt doc/ferm.html $(DOCDIR)
	install -m 644 doc/{import-,}ferm.1 $(MANDIR)
	gzip -f9 $(MANDIR)/{import-,}ferm.1

uninstall:
	rm -rf $(DOCDIR)
	rm -f $(MANDIR)/{import-,}ferm.1{,.gz}
	rm -f $(PREFIX)/sbin/{import-,}ferm

#
# misc targets
#

.PHONY: www ftp pub

upload: doc/ferm.html
	scp NEWS doc/ferm.html foo-projects.org:/var/www/ferm.foo-projects.org/download/2.0/
	scp examples/*.ferm foo-projects.org:/var/www/ferm.foo-projects.org/download/examples/

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
