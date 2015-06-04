#!/usr/bin/perl -w
#
# Shallalist to DNS RPZ
# Author: Mark Page [m.e.page_at_gmail.com]
# Modified: Sun May 11 06:19:05 CDT 2014
#
# Examples:
#   perl make-shalla-rpz.pl (no arg, creates NXDOMAIN CNAME ".")
#   perl make-shalla-rpz.pl A 192.168.2.1 (creates "A" redirect)
#   perl make-shalla-rpz.pl CNAME nowhere.local (creates "CNAME" redirect)
#   perl make-shalla-rpz.pl CNAME CATEGORY.local (creates category "CNAME" redirect)
#
use strict;
use warnings;

my ($urls);
my @categories = ('adv','porn','warez','anonvpn','spyware','redirector','dating','drug','gamble','remotecontrol');$

for my $c (0 .. (scalar(@categories) - 1)) {
        open (my $list,'<',"./BL/$categories[$c]/domains");
        chomp(my @domains = <$list>);
        close($list);

        for my $d (0 .. (scalar(@domains) - 1)) {
                $urls->{lc($domains[$d])} = $categories[$c];
        }
}

open (my $db,'>',"./db.srpz.local");
print $db '$TTL    604800
@       IN      SOA     localhost.local. hostmaster.local. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      localhost.local.
@       IN      A       127.0.0.1
@       IN      AAAA    ::1
;
';

while (my ($key, $value) = each(%$urls) ) {
        my $redirect = 'CNAME .';

        if (defined($ARGV[0]) and defined($ARGV[1])) {
                $redirect = uc($ARGV[0]) . ' ' . $ARGV[1];
                if ($ARGV[1] =~ m/CATEGORY/) {
                        $redirect =~ s/CATEGORY/$value/;
                }
        }

        if (substr($key,0,1) ne '.') {
                print $db $key . ' IN ' . $redirect . "\n";
                print $db '*.' . $key . ' IN ' . $redirect . "\n";
        }
}
close($db);

exit;

__END__