# path of the old and the new ferm binary
OLD_FERM = /usr/bin/ferm
NEW_FERM = ../src/ferm

# a list of all ferm scripts which should be tested with iptables
FERM_SCRIPTS = positive/flush positive/multimod positive/negated-varlist positive/policyorder
FERM_SCRIPTS_iptables = positive/bug positive/iptables-targets positive/masqto positive/mod params/owner positive/state positive/tables2 positive/TCPMSS positive/ttlset positive/ulog positive/varlists
FERM_SCRIPTS_iptables += $(wildcard modules/*.ferm) $(wildcard targets/*.ferm) $(wildcard protocols/*.ferm) $(wildcard misc/*.ferm)
FERM_SCRIPTS_iptables += $(FERM_SCRIPTS_ipchains)

all:

clean:
	rm -rf tmp

define gen_template
tmp/$(1)/%.$(2): PATCHFILE = $$(shell test $(2) = "OLD" -a -f "patch/$$(<).$(1)" && echo "patch/$$(<).$(1)" )
tmp/$(1)/%.$(2): % $$($(2)_FERM) ./canonical.pl
	mkdir -p `dirname $$@`
	if test $(2) = "OLD" -a -f $$(basename $$<).result; then cp $$(basename $$<).result $$@.tmp1; else $$($(2)_FERM) --use $(1) --lines --noexec $$< >$$@.tmp1; fi
	if test -n "$$(PATCHFILE)"; then patch -i$$(PATCHFILE) $$@.tmp1; fi
	./canonical.pl <$$@.tmp1 >$$@.tmp2
	mv $$@.tmp2 $$@
endef

$(foreach frontend,iptables,$(foreach version,OLD NEW,$(eval $(call gen_template,$(frontend),$(version)))))

%.check: %.OLD %.NEW
	diff -u $^
	touch $@

.PHONY : check
check: $(foreach frontend,iptables,$(patsubst %,tmp/$(frontend)/%.check,$(FERM_SCRIPTS) $(FERM_SCRIPTS_$(frontend))))
