package Cerdo::ReadRules;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;

@EXPORT = qw(ALL);
$VERSION = '0.1';

=head2 parse_all_rule_files

 Opens all the rule files from the directories that is given to it,
 parses them, and return $rules in a hash.
 It takes a array list of directories as input.

 Example:
   my $rules = {};
   my @dirs = ["/tmp/vrt/", "/tmp/et/", "/tmp/et-pro/"];
   $rules = parse_all_rule_files (@dirs);

=cut

sub parse_all_rule_files {
    my @DIRS = shift;
    my @FILES;

    # For each dir:

    foreach my $DIR ( @DIRS ) {
        # Open the directory
        if( opendir( ODIR, $DIR ) ) {
           # Find rule files in dir (*.rules)
           while( my $FILE = readdir( ODIR ) ) {
              next if( ( "." eq $FILE ) || ( ".." eq $FILE ) );
              next unless ($FILE =~ /.*\.rules$/);
              push( @FILES, $FILE ) if( -f "$DIR$FILE" );
           }
           closedir( ODIR );
        } else {
            warn "[!] Error opening dir: $DIR";
            exit 1;
        }
        foreach my $FILE ( @FILES ) {
           my $result = get_rules ("$DIR$FILE");
           if ($result == 1) {
              warn "[*] Couldn't parse $RULESDIR$FILE: $!\n";
           }
        }
    }
}

=head2 get_rules

 This sub extracts the rules from a rules file.
 Takes $file as input parameter. Returns a %hash with rules.

=cut

sub get_rules {
    my $RFILE = shift;
    my $RDB = {};

    if (open (FILE, $RFILE)) {
        print "Found rules file: ".$RFILE."\n" if $DEBUG;
        # Verify the rules in the rule files
        LINE:
        while (my $rule = readline FILE) {
            chomp $rule;
            next LINE unless($rule); # empty line

            $rule =~ /^\#? ?(drop|alert|log|pass|activate|dynamic)\s+(\S+?)\s+(\S+?)\s+(\S+?)\s+(\S+?)\s+(\S+?)\s+(\S+?)\s+\((.*)\)$/;
            my ($action, $proto, $sip, $sport, $dir, $dip, $dport, $options) = ($1, $2, $3, $4, $5, $6, $7, $8);
            unless($rule) {
                warn "[*] Error: Not a valid rule in: '$RFILE'" if $DEBUG;
                warn "[*] RULE: $rule" if $DEBUG;
                next LINE;
            }

            if (not defined $options) {
                warn "[*] Error: Options missing in rule: '$RFILE'" if $DEBUG;
                warn "[*] RULE: $rule" if $DEBUG;
                next LINE;
            }

            # ET rules had at some point: "sid: 2003451;" Which is not illigal...
            unless( $options =~ /sid:\s*([0-9]+)\s*;/ ) {
                warn "[*] Error: No sid found in rule options: '$RFILE'" if $DEBUG;
                warn "[*] RULE: $options" if $DEBUG;
                next LINE;
            }
            my $sid = $1;

            $options =~ /msg:\s*\"(.*?)\"\s*;/;
            my $msg = $1;

            $options =~ /rev:\s*(\d+?)\s*;/;
            my $rev = $1;

            my $enabled = 0;
            # This also removes comments in rules (making them active)
            if ( $rule =~ s/^# ?//g ) {
               $enabled = 0;
            } else {
                $enabled = 1;
            }
            # Things should be "OK" now to send to the hash-DB
            # push (@{$RDB{$sid}}, [ $rule ]);
            $RDB->{$sid}->{'rule'}      = $rule;
            $RDB->{$sid}->{'enabled'}   = $enabled;
            $RDB->{$sid}->{'action'}    = $action;
            $RDB->{$sid}->{'protocol'}  = $proto;
            $RDB->{$sid}->{'src_ip'}    = $sip;
            $RDB->{$sid}->{'src_port'}  = $sport;
            $RDB->{$sid}->{'direction'} = $dir;
            $RDB->{$sid}->{'dst_ip'}    = $dip;
            $RDB->{$sid}->{'dst_port'}  = $dport;
            $RDB->{$sid}->{'message'}   = $msg;
            $RDB->{$sid}->{'options'}   = $options;
        }
      close FILE;
    }
    return $RDB;
}



1;
