package Cerdo::Config;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;

@EXPORT = qw(ALL);
$VERSION = '0.1';

=head2

 Reads a Cerdo config file.
 Takes $file as input.
 Returns %hash with config options.

=cut

sub read_config {
    my $file = shift;
    my $config = {};

    open(CONFIG,$file);
    while (my $line = <CONFIG>) {
        chomp($line);
        $line =~ s/\#.*//;
        next if undef $line;
        # PARAMETER = SOME_VALUE
        my ($key, $value) = ($line =~ m/(\w+)\s*=\s*(.*)$/);
        $config->{$key} = $value;
    }
    return $config;
}

1;
