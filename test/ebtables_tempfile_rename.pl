#!/usr/bin/perl -w

# This script renames ebtables temporary file suffixes consistently
# from the result files so that tests can be done.

use strict;

my $matches = 0;

while (<>) {
    s/--atomic-file \/tmp\/ferm.(\w+) /--atomic-file \/tmp\/ferm.1 /;
    s/--atomic-file \/tmp\/ferm.(\w+) --atomic-save/--atomic-file \/tmp\/ferm.0 --atomic-save/;
    print $_;
}

