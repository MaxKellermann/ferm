Summary: ferm - For Easy Rule Making
Name: ferm
Version: 1.0pl1
Release: 1
Group: system/firewalls
Copyright: GPL
Source: %{name}-%{version}.tar.gz
BuildRoot: /tmp/%{name}-%{version}-root
URL: http://ferm.foo-projects.org/
BuildArchitectures: noarch
Requires: perl
Packager: A. Kok <sofar@foo-projects.org>

%description
Ferm is a tool to maintain complex firewalls, without having the
trouble to rewrite the complex rules over and over again. Ferm
allows the entire firewall rule set to be stored in a separate
file, and to be loaded with one command. The firewall configuration
resembles structured programming-like language, which can contain
levels and lists.

%prep
%setup
mkdir -p $RPM_BUILD_ROOT
cp -R ./* $RPM_BUILD_ROOT

%install
make install

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%dir /examples
/CHANGES
/AUTHORS
/COPYING
/README
/TODO
/ferm.txt
/ferm.html
/ferm.1
/examples/complex-server
/examples/workstation
/examples/iptables
/examples/realistic
/Makefile
%defattr(0700,root,root)
/ferm

%changelog
