#!/usr/bin/perl -w
# $Id$
#
# Canonicalize ferm output. You can use this script to check whether
# the output from two ferm versions are functionally identical. This
# is used in the compatibility tests.
#
# Author: Max Kellermann (max@duempel.org)

use strict;

sub shell_unescape {
    my $token = shift;
    $token =~ s/\\'/'/g;
    $token =~ s/^(["'])(.*)\1/$2/s;
    return $token;
}

my $data;

while (<>) {
    next if /^\s*(?:#.*)?$/s;

    # workaround: not supported in ipchains
    next
      if /cannot set the policy for non-built in chains, exiting|Cannot create new chains if using ipfwadm|Ipfwadm allows only accept, masq, deny and reject targets/;

    # execute backticks
    s/`(.*?)`/`$1`/egs;

    if (s/^(ip6?)tables //) {
        my $item;

        $item->{domain} = $1;

        # get table
        my $table;
        s/-t (\w+)/$table = $1; ''/eg;
        $table = 'filter'
          unless defined $table;

        # get command and chain
        my ($command, $chain);

        if (s/-P (\w+) (\w+)//g) {
            if ($2 eq 'ACCEPT') {
                delete $data->{iptables}{$table}{$1}{policy}
                  if exists $data->{iptables}{$table}
                    and exists $data->{iptables}{$table}{$1};
            } else {
                $data->{iptables}{$table}{$1}{policy} = $2;
            }
            next;
        }

        s/-([ALFZNXE])(?: ([-\w]+))?/($command, $chain) = ($1, $2); ''/eg;

        next if $command eq 'F' or $command eq 'X';

        if ($command eq 'N') {
            if (defined $chain) {
                push @{$data->{iptables}{$table}{$chain}{rules}}, $command;
            } else {
                push @{$data->{iptables}{$table}{rules}}, $command;
            }
            next;
        }

        die 'no chain specified'
          unless defined $chain;

        # module list
        my %modules;
        s/-m (\w+)/$modules{$1} = 1; ''/eg;
        $item->{modules} = [ grep { not /^(?:tcp|udp|icmp)$/ } keys %modules ];

        # short to long
        s/-j\b/--jump/g;
        s/-i\b/--in-interface/g;
        s/-o\b/--out-interface/g;
        s/-p\b/--protocol/g;
        s/-d\b/--destination/g;
        s/-s\b/--source/g;
        s/-f\b/--fragment/g;

        # evaluate options with zero, one, two parameters
        s/(?:(!)\s*)?--(syn|clamp-mss-to-pmtu|set|rcheck|log-tcp-sequence|log-tcp-options|log-ip-options|continue|save-mark|restore-mark|fragment|ecn-tcp-cwr|ecn-tcp-ece|physdev-is-(?:in|out|bridged)|strict|next|frag(res|first|more|last)|nodst|ecn-tcp-remove|ahres|soft|rt-0-res|rt-0-not-strict|ashort)(?:\s|$)/$item->{$2} = $1; ''/eg;
        s/--(tcp-flags|chunk-types)\s+(?:(\!)\s+)?(\S+)\s+(\S+)/$item->{$1} = [ $2, $3, $4 ]; ''/eg;
        s/(?:(!)\s*)?--(iplimit-above|src-range|dst-range|tos)\s+(\S+)/$item->{$2} = [ $1, $2 ]; ''/eg;
        s/--(\w[-\w]*)\s+(!)?\s*(".*?"|'.*?'|\S+)/$item->{$1} = (defined $2 ? "$2\t" : "") . shell_unescape($3); ''/eg;

        # after we parsed everything we know, nothing must be left
        die "unparsed rest from line $.: $_"
          if /\S/;

        # add this item
        push @{$data->{iptables}{$table}{$chain}{rules}}, $item;
    } elsif (s/^ipchains //) {
        my $item;

        # get command and chain
        my ($command, $chain);

        if (s/-P (\w+) (\w+)//g) {
            $data->{ipchains}{$1}{policy} = $2;
            next;
        }

        s/-([AFZNX])(?: (\w+))?/($command, $chain) = ($1, $2); ''/eg;

        if ($command eq 'F' or $command eq 'N' or $command eq 'X') {
            if (defined $chain) {
                delete $data->{ipchains}{$chain}{rules};
            } else {
                delete $data->{ipchains};
            }
            next;
        }

        die 'no chain specified'
          unless defined $chain;

        # short to long
        s/-j\b/--jump/g;
        s/-i\b/--interface/g;
        s/-d\b/--destination/g;
        s/-s\b/--source/g;
        s/-l\b/--log/g;
        s/-p\b/--protocol/g;
        s/-y\b/--syn/g;

        # evaluate options with zero, one parameter
        s/(!\s*)?--(log|syn)\b/$item->{$2} = $1; ''/eg;
        s/--(jump|protocol|interface|destination|source|protocol|
             dport|destination-port|sport|source-port
            )\s+(".*?"|(?:!\s*)?\S+)/$item->{$1} = $2; ''/egx;

        # after we parsed everything we know, nothing must be left
        die "unparsed rest from line $.: $_"
          if /\S/;

        # add this item
        push @{$data->{ipchains}{$chain}{rules}}, $item;
    } elsif (s/^ipfwadm //) {
        my $item;

        # get chain
        s/-([IOF])//
          or die "No chain in line $.";

        my $chain = $1;

        # handle command
        if (s/-p (\w+)//) {
            $data->{ipfwadm}{$chain}{policy} = $1;
            next;
        }

        $item->{policy} = $1
          if s/-a (\w+)//;

        # evaluate options
        s/-([m])/$item->{$1} = 1; ''/eg;
        s/-([PVW])\s+((?:!\s*)?\S+)/$item->{$1} = $2; ''/egx;

        # after we parsed everything we know, nothing must be left
        die "unparsed rest from line $.: $_"
          if /\S/;

        # add this item
        push @{$data->{ipfwadm}{$chain}{rules}}, $item;
    } else {
        die "syntax error line $.";
    }
}

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
print Dumper($data);
