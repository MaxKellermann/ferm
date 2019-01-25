#!/usr/bin/perl -w

# This script renames ebtables temporary file suffixes consistently
# from the result files so that tests can be done.

use strict;

my $matches = 0;

while (<>) {
    if ($matches eq 0) {
        s/--atomic-file \/tmp\/ferm.(\w+) /--atomic-file \/tmp\/ferm.0 /;
        $matches = 1;
    } else {
        s/--atomic-file \/tmp\/ferm.(\w+) /--atomic-file \/tmp\/ferm.1 /;
    }
    print $_;
}

