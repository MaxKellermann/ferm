TOPDIR = ..
include $(TOPDIR)/config.mk

# a list of all ferm scripts which should be tested with iptables
FERM_SCRIPTS = positive/flush positive/multimod positive/policyorder
FERM_SCRIPTS += positive/bug positive/iptables-targets positive/masqto positive/mod params/owner positive/state positive/tables2 positive/TCPMSS positive/ttlset positive/ulog positive/varlists
FERM_SCRIPTS += $(wildcard modules/*.ferm) $(wildcard targets/*.ferm) $(wildcard protocols/*.ferm) $(wildcard misc/*.ferm)
FERM_SCRIPTS += $(wildcard ipv6/*.ferm)

all:

clean:
	rm -rf tmp

tmp/%.OLD: PATCHFILE = $(shell test -f "patch/$(<).iptables" && echo "patch/$(<).iptables" )
tmp/%.OLD: % $(OLD_FERM) canonical.pl
	mkdir -p $(dir $@)
	if test -f $(basename $<).result; then cp $(basename $<).result $@.tmp1; else perl $(OLD_FERM) $(OLD_OPTIONS) $< >$@.tmp1; fi
	if test -n "$(PATCHFILE)"; then patch -i$(PATCHFILE) $@.tmp1; fi
	perl canonical.pl <$@.tmp1 >$@.tmp2
	mv $@.tmp2 $@

tmp/%.NEW: % $(NEW_FERM) ./canonical.pl
	mkdir -p $(dir $@)
	perl $(NEW_FERM) $(NEW_OPTIONS) $< >$@.tmp1
	perl canonical.pl <$@.tmp1 >$@.tmp2
	mv $@.tmp2 $@

%.check: %.OLD %.NEW
	diff -u $^
	touch $@

.PHONY : check
check: $(patsubst %,tmp/%.check,$(FERM_SCRIPTS))
