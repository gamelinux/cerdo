#
# Copyright (C) 2002, 2007 by Peder Stray <peder@ifi.uio.no>
# Copyright (C) 2010 by Edward Fjellskaal <edwardfjellskaal@gmail.com>
#

# use Cerdo::State C => 'jalla.conf';
# C => [ 'jalla.conf', readonly => 1 ]

package Cerdo::State;

use strict;
use Data::Dumper;
use Carp;

my %namespace;

sub import {
    my($class, %ns) = @_;

    for my $ns (keys %ns) {
	my($ret,$file,%opt);

	$file = $ns{$ns};
	($file,%opt) = @$file if ref $file;

	$ret = do $file;

	if ($@) {
	    croak "Parse failed for $file:\n  $@";
	    next;
	}

#	warn "couldn't do $file: $!"    unless defined $ret;
#	warn "couldn't run $file"       unless $ret;

	if ($ret && $ret =~ /\D/ && $ret ne $ns) {
	    no strict 'refs';
	    *{$ns.'::'} = \%{$ret.'::'};
	    *{$ret.'::'} = {};
	}

	$namespace{$ns} = { 
			   file   => $file,
			   write  => !$opt{readonly},
			  };
    }
}

END {
    my $file;
    use vars qw($entry @entry %entry);
    
    local $Data::Dumper::Indent   = 1;
    local $Data::Dumper::Sortkeys = 1;

    return if $^C;	# just compile checking
    return if $?;	# return if the program died.

    for my $ns (keys %namespace) {
	$file = $namespace{$ns}{file};

	next unless $namespace{$ns}{write};

	unlink "$file.old";
	rename "$file", "$file.old";
	eval {
	    no strict 'refs';

	    my($key,$val);
	    local *RC;
	    open RC, ">:utf8", $file or die;
	    print RC "# data file for @{[$0 =~ m,.*/(.*),]} -*- Mode: perl -*-\n" or die;
	    print RC "# written @{[scalar localtime]}\n\n" or die;
	    print RC "package $ns;\n\n" or die;
	    print RC "use utf8;\n\n" or die;
    
	    while (($key,$val) = each %{$ns.'::'}) {
		local(*entry) = $val;
		if (defined $entry) {
		    #print RC Data::Dumper->Dump([$entry],["*$key"]) or die;
            print RC Data::Dumper->Dump([$entry],['$'.$key]) or die;
		}
		if (defined @entry) {
		    print RC Data::Dumper->Dump([\@entry],["*$key"]) or die;
            #print RC Data::Dumper->Dump([\@entry],['@'.$key]) or die;
		}
		if (defined %entry) {
		    print RC Data::Dumper->Dump([\%entry],["*$key"]) or die;
            #print RC Data::Dumper->Dump([\%entry],[$key]) or die;
		}
	    }
	    print RC "\n__"."PACKAGE"."__;\n" or die;
	    close RC or die;
	};
	if ($@) {
	    carp "Writing of $ns to $file failed:\n  $@\n  $!";
	    unlink $file;
	    link "$file.old", "$file";
	}
    }
}

1;
