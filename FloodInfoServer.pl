use Time::Date;
use HTTP::Daemon;
use Tie::File;
use threads;

#This program is free software: you can redistribute it and/or modify it under the terms of the Affero GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

#This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

my $webServer;
my $d = HTTP::Daemon->new(LocalPort => 8081,
                          Listen => 20) || die;
print "Please contact me at: <URL:", $d->url, ">\n";

my $InondesKMLAddress = 'KML/Flooded.kml';
my $CavesKMLAddress = 'KML/Caves.kml';
my $TelephoneKMLAddress = 'KML/Telephone.kml';
my $PowerKMLAddress = 'KML/Power.kml';
my $WaterKMLAddress = 'KML/Water.kml';
my $GazKMLAddress = 'KML/Gaz.kml';
my $DrainageKMLAddress = 'KML/Drainage.kml';
my $ImpactedKMLAddress = 'KML/Impacted.kml';
my $CSVAddress = "FloodInfoDB.csv";

open(my $Inondesfh,'>>', $InondesKMLAddress) or die "open: $!";
open(my $Cavesfh, '>>', $CavesKMLAddress) or die "open: $!";
open(my $Telephonefh, '>>', $TelephoneKMLAddress) or die "open: $!";
open(my $Powerfh, '>>', $PowerKMLAddress) or die "open: $!";
open(my $Waterfh, '>>', $WaterKMLAddress) or die "open: $!";
open(my $Gazfh, '>>', $GazKMLAddress) or die "open: $!";
open(my $Drainagefh, '>>', $DrainageKMLAddress) or die "open: $!";
open(my $Impactedfh, '>>', $ImpactedKMLAddress) or die "open: $!";
open(my $CSVfh, '>>', $CSVAddress) or die "open: $!";

print($Inondesfh "<?xml version=\"1.0\" encoding=\"UTF-8\"?><kml xmlns=\"http://earth.google.com/kml/2.0\"> <Document>\n");
print($Cavesfh "<?xml version=\"1.0\" encoding=\"UTF-8\"?><kml xmlns=\"http://earth.google.com/kml/2.0\"> <Document>\n");
print($Telephonefh "<?xml version=\"1.0\" encoding=\"UTF-8\"?><kml xmlns=\"http://earth.google.com/kml/2.0\"> <Document>\n");
print($Powerfh "<?xml version=\"1.0\" encoding=\"UTF-8\"?><kml xmlns=\"http://earth.google.com/kml/2.0\"> <Document>\n");
print($Waterfh "<?xml version=\"1.0\" encoding=\"UTF-8\"?><kml xmlns=\"http://earth.google.com/kml/2.0\"> <Document>\n");
print($Gazfh "<?xml version=\"1.0\" encoding=\"UTF-8\"?><kml xmlns=\"http://earth.google.com/kml/2.0\"> <Document>\n");
print($Drainagefh "<?xml version=\"1.0\" encoding=\"UTF-8\"?><kml xmlns=\"http://earth.google.com/kml/2.0\"> <Document>\n");
print($Impactedfh "<?xml version=\"1.0\" encoding=\"UTF-8\"?><kml xmlns=\"http://earth.google.com/kml/2.0\"> <Document>\n");


print($CSVfh "Inondé;Cave Inondée;Électricité;Eau Potable;Assainissement;Telephone;Gaz;Impactés;Latitude;Longitude;Timestamp\n");
my $timestamp = 0;

my $isFlooded = 0;
my $isCaveFlooded = 0;
my $hasPower = 0;
my $hasWater = 0;
my $hasDrainage = 0;
my $hasTelephone = 0;
my $hasGaz = 0;
my $numImpacted = 0;
my $mLatitude = 0;
my $mLongitude = 0;
my $i = 0;

while (my $c = $d->accept) {

    
    #delete the last line of the KMLs	
    if($i>0)
	{
	tie @lines, Tie::File, $InondesKMLAddress or die "can't update : $!"; delete $lines[-1]; 
	tie @lines, Tie::File, $CavesKMLAddress or die "can't update : $!"; delete $lines[-1];
	tie @lines, Tie::File, $TelephoneKMLAddress or die "can't update : $!"; delete $lines[-1];
	tie @lines, Tie::File, $PowerKMLAddress or die "can't update : $!"; delete $lines[-1];
	tie @lines, Tie::File, $WaterKMLAddress or die "can't update : $!"; delete $lines[-1];
	tie @lines, Tie::File, $GazKMLAddress or die "can't update : $!"; delete $lines[-1];
	tie @lines, Tie::File, $DrainageKMLAddress or die "can't update : $!"; delete $lines[-1];
	tie @lines, Tie::File, $ImpactedKMLAddress or die "can't update : $!"; delete $lines[-1];
	}

    	threads->create(\&process_one_req, $c)->detach();
	$i++;
	print "FloodInfo Request Handled #$i\n";


}

sub process_one_req {
    my $c = shift;
    my $r = $c->get_request;
    if ($r) {
        if ($r->method eq "POST") {
	$content = $r->content();
	my $NOW = Time::Date->now;
	$timestamp = ($NOW -> {epoch}+60);

	if($content=~ /isFlooded=(.*)&isCaveFlooded=(.*)&hasPower=(.*)&hasWater=(.*)&hasDrainage=(.*)&hasTelephone=(.*)&hasGaz=(.*)&numImpacted=(.*)&mLatitude=(.*)&mLongitude=(.*)/)
		{   
		$isFlooded = $1;
		$isCaveFlooded = $2;
		$hasPower = $3;
		$hasWater = $4;
		$hasDrainage = $5;
		$hasTelephone = $6;
		$hasGaz = $7;
		$numImpacted = $8;
		$mLatitude = $9;
		$mLongitude = $10;
		}
	print($Inondesfh "<Style id=\"My_Style\"><IconStyle> <Icon> <href>https://home.pjeremie.org/img/$isFlooded.png</href> </Icon></IconStyle></Style><Placemark><name>$timestamp</name><styleUrl>#My_Style</styleUrl><Point><coordinates>$mLongitude,$mLatitude</coordinates></Point></Placemark>\n");
	print($Cavesfh "<Style id=\"My_Style\"><IconStyle> <Icon> <href>https://home.pjeremie.org/img/$isCaveFlooded.png</href> </Icon></IconStyle></Style><Placemark><name>$timestamp</name><styleUrl>#My_Style</styleUrl><Point><coordinates>$mLongitude,$mLatitude</coordinates></Point></Placemark>\n");
	print($Telephonefh "<Style id=\"My_Style\"><IconStyle> <Icon> <href>https://home.pjeremie.org/img/$hasTelephone.png</href> </Icon></IconStyle></Style><Placemark><name>$timestamp</name><styleUrl>#My_Style</styleUrl><Point><coordinates>$mLongitude,$mLatitude</coordinates></Point></Placemark>\n");
	print($Powerfh "<Style id=\"My_Style\"><IconStyle> <Icon> <href>https://home.pjeremie.org/img/$hasPower.png</href> </Icon></IconStyle></Style><Placemark><name>$timestamp</name><styleUrl>#My_Style</styleUrl><Point><coordinates>$mLongitude,$mLatitude</coordinates></Point></Placemark>\n");
	print($Waterfh "<Style id=\"My_Style\"><IconStyle> <Icon> <href>https://home.pjeremie.org/img/$hasWater.png</href> </Icon></IconStyle></Style><Placemark><name>$timestamp</name><styleUrl>#My_Style</styleUrl><Point><coordinates>$mLongitude,$mLatitude</coordinates></Point></Placemark>\n");
	print($Gazfh "<Style id=\"My_Style\"><IconStyle> <Icon> <href>https://home.pjeremie.org/img/$hasGaz.png</href> </Icon></IconStyle></Style><Placemark><name>$timestamp</name><styleUrl>#My_Style</styleUrl><Point><coordinates>$mLongitude,$mLatitude</coordinates></Point></Placemark>\n");
	print($Drainagefh "<Style id=\"My_Style\"><IconStyle> <Icon> <href>https://home.pjeremie.org/img/$hasDrainage.png</href> </Icon></IconStyle></Style><Placemark><name>$timestamp</name><styleUrl>#My_Style</styleUrl><Point><coordinates>$mLongitude,$mLatitude</coordinates></Point></Placemark>\n");
	print($Impactedfh "<Style id=\"My_Style\"><IconStyle> <Icon> <href>https://home.pjeremie.org/img/$numImpacted.png</href> </Icon></IconStyle></Style><Placemark><name>$timestamp</name><styleUrl>#My_Style</styleUrl><Point><coordinates>$mLongitude,$mLatitude</coordinates></Point></Placemark>\n");
   	print($CSVfh "$isFlooded;$isCaveFlooded;$hasPower;$hasWater;$hasDrainage;$hasTelephone;$hasGaz;$numImpacted;$mLatitude;$mLongitude;$timestamp\n");

	print($Inondesfh "</Document></kml>");
	print($Cavesfh "</Document></kml>");
	print($Telephonefh "</Document></kml> ");
	print($Powerfh "</Document></kml>");
	print($Waterfh "</Document></kml> ");
	print($Gazfh "</Document></kml> ");
	print($Drainagefh "</Document></kml> ");
	print($Impactedfh "</Document></kml> ");
    	$c->send_basic_header;
   	$c->print("Content-Type: text/plain");
   	$c->send_crlf;
   	$c->send_crlf;
   	$c->print("OK\n");
        }
    }
    $c->close;
    undef($c);
}


exit;
close $Inondesfh;
close $Cavesfh;
close $Telephonefh;
close $Gazfh;
close $Waterfh;
close $Powerfh;
close $Drainagefh;
close $Impactedfh;
close $CSVfh;
