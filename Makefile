#
# Makefile for ferm
#

TOPDIR = .
include $(TOPDIR)/config.mk

VERSION := $(shell $(PERL) src/ferm --version | awk '{print $$2}' | head -1 | tr -d ',')

DISTDIR = build/ferm-$(VERSION)

.PHONY: all clean

all: doc/ferm.txt doc/ferm.html doc/ferm.1 doc/import-ferm.1

clean:
	rm -rf build
	rm -f doc/ferm.txt doc/ferm.html doc/ferm.1 doc/import-ferm.1 *.tmp

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

EXCLUDE_IMPORT = test/misc/subchain-domains.ferm test/misc/ipfilter.ferm test/ipv6/mixed.ferm
IMPORT_SCRIPTS = $(filter-out $(EXCLUDE_IMPORT) test/arptables/% test/ebtables/%,$(FERM_SCRIPTS))

# just a hack
RESULT_SED += -e 's,--protocol,-p,g'
RESULT_SED += -e 's,--in-interface,-i,g'
RESULT_SED += -e 's,--out-interface,-o,g'
RESULT_SED += -e 's,--destination ,-d ,g'
RESULT_SED += -e 's,--source ,-s ,g'
RESULT_SED += -e 's,--match ,-m ,g'
RESULT_SED += -e 's,--jump,-j,g'
RESULT_SED += -e 's,--goto,-g,g'
RESULT_SED += -e 's,--fragment,-f,g'

EB_ARP_RESULT_SED = -e 's,--jump,-j,g'

$(STAMPDIR)/test/arptables/%.result: test/arptables/%.ferm src/ferm
	@mkdir -p $(dir $@)
	$(PERL) src/ferm --test --slow $< |sed $(EB_ARP_RESULT_SED) >$@

$(STAMPDIR)/test/ebtables/%.result: test/ebtables/%.ferm src/ferm
	@mkdir -p $(dir $@)
	$(PERL) src/ferm --test --slow $< |sed $(EB_ARP_RESULT_SED) >$@

$(STAMPDIR)/%.result: %.ferm src/ferm
	@mkdir -p $(dir $@)
	$(PERL) src/ferm --test --slow --noflush $< |sed $(RESULT_SED) >$@

$(STAMPDIR)/%.SAVE: %.ferm src/ferm
	@mkdir -p $(dir $@)
	$(PERL) src/ferm --test $< >$@.tmp
	grep -v '^#' <$@.tmp >$@

$(STAMPDIR)/test/ipv6/%.IMPORT: export FERM_DOMAIN=ip6
$(STAMPDIR)/%.IMPORT: $(STAMPDIR)/%.SAVE src/import-ferm
	$(PERL) src/import-ferm $< >$@

$(STAMPDIR)/%.SAVE2: $(STAMPDIR)/%.IMPORT src/ferm
	$(PERL) src/ferm --test --fast $< |grep -v '^#' >$@

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
	install -m 755 src/ferm src/import-ferm $(DISTDIR)/src
	install -m 644 doc/ferm.pod doc/ferm.txt doc/ferm.html doc/ferm.1 doc/import-ferm.1 $(DISTDIR)/doc
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
	install -m 755 src/ferm src/import-ferm $(PREFIX)/sbin/

	install -d -m 755 $(DOCDIR) $(MANDIR)
	install -m 644 doc/ferm.txt doc/ferm.html $(DOCDIR)
	install -m 644 doc/ferm.1 doc/import-ferm.1 $(MANDIR)
	gzip -f9 $(MANDIR)/ferm.1 $(MANDIR)/import-ferm.1

uninstall:
	rm -rf $(DOCDIR)
	rm -f $(MANDIR)/ferm.1 $(MANDIR)/import-ferm.1
	rm -f $(PREFIX)/sbin/ferm $(PREFIX)/sbin/import-ferm

#
# misc targets
#

.PHONY: upload

upload: doc/ferm.html
	scp NEWS doc/ferm.html foo-projects.org:/var/www/ferm.foo-projects.org/download/2.1/
	scp examples/*.ferm foo-projects.org:/var/www/ferm.foo-projects.org/download/examples/
