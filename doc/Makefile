TOPDIR = ..
include $(TOPDIR)/config.mk

all: ferm.txt ferm.html ferm.1 

clean:
	rm -f ferm.txt ferm.html ferm.1 *.tmp

ferm.txt: ferm.pod
	pod2text $< > $@

ferm.html: ferm.pod
	pod2html $< --netscape --flush > $@

ferm.1: ferm.pod
	pod2man --section=1 --release="ferm $(VERSION)" \
		--center="FIREWALL RULES MADE EASY" \
		--official $< > $@

install: all
	install -d -m 755 $(DOCDIR) $(MANDIR)
	install -m 644 ferm.txt ferm.html $(DOCDIR)
	install -m 644 ferm.1 $(MANDIR)
	gzip -9 $(MANDIR)/ferm.1

uninstall:
	rm -rf $(DOCDIR)
	rm -f $(MANDIR)/ferm.1 $(MANDIR)/ferm.1.gz
