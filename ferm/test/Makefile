# path of the old and the new ferm binary
OLD_FERM = /usr/bin/ferm
NEW_FERM = ../src/ferm

# a list of all ferm scripts which should be tested with iptables,
# ipchains and ipfwadm
FERM_SCRIPTS = params/owner positive/bug positive/flush positive/iptables-targets positive/kwbug positive/masqto positive/mod positive/multimod positive/multipolicy positive/multivar positive/negated-varlist positive/plbug positive/policyorder positive/state positive/SUSE positive/tables2 positive/TCPMSS positive/ttlset positive/ulog
FERM_SCRIPTS_iptables = positive/logLOG positive/varlists

all:

clean:
	rm -rf tmp

define gen_template
tmp/$(1)/%.$(2): % $$($(2)_FERM) ./canonical.pl
	mkdir -p `dirname $$@`
	$$($(2)_FERM) --use $(1) --lines --noexec $$< |./canonical.pl >$$@.tmp
	mv $$@.tmp $$@
endef

$(foreach frontend,iptables ipchains ipfwadm,$(foreach version,OLD NEW,$(eval $(call gen_template,$(frontend),$(version)))))

%.check: %.OLD %.NEW
	diff -u $^
	touch $@

.PHONY : check
check: $(foreach frontend,iptables ipchains ipfwadm,$(patsubst %,tmp/$(frontend)/%.check,$(FERM_SCRIPTS) $(FERM_SCRIPTS_$(frontend))))
