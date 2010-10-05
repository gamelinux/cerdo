package Cerdo;

$VERSION = "0.001";
sub Version { $VERSION; }

require 5.005;
require Cerdo::ReadRules;
require Cerdo::WriteRules;
require Cerdo::FlowBits;
require Cerdo::FetchRules;
require Cerdo::State;
#use Cerdo::Load ();

1;

_END__

=head1 NAME

Cerdo - The defacto TUI for handling snort rules!

=head1 SYNOPSIS

  use Cerdo;
  print "This is Cerdo-$Cerdo::VERSION\n";

=head1 DESCRIPTION

 Cerdo aims at managing all your IPS/IDS sensor rulesets,
 be it Suricata, Snort or others, from the console in a way
 that gives you a more visual view then other console tools.

=cut

=head1 AUTHOR

 Edward Fjellskaal <edwardfjellskaal@gmail.com>

=head1 COPYRIGHT

 Copyright (C) 2010, Edward Fjellskaal <edwardfjellskaal@gmail.com>

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

=cut
# ҈ ☃ ☠ ҉
