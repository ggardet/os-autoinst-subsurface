#/usr/lib/perl
# 2018.04.23: Update to handle multiple area

use strict;
use warnings;
use JSON qw( );
use Path::Tiny qw(path);
use File::Basename;
use Text::Template;

my $num_args = $#ARGV + 1;
if ($num_args != 1) {
	print "Usage: check_match_area_from_needles.pl <needles folder>\n";
	exit;
}

# Needles folder
my $folder = $ARGV[0];

# HTML template
my $template_filename = "templates/template_image.html";

# List all needles/*.json
opendir(DIR, "$folder");
my @files = grep(/\.json$/,readdir(DIR));
closedir(DIR);

# For each file, generate an HTML page to display PNG image and match area
foreach my $file (@files) {
	print "$folder/$file\n";
	my $json_filename = "$folder/$file";
	
	
	my $json_text = do {
		open(my $json_fh, "<:encoding(UTF-8)", $json_filename)
		or die("Can't open $json_filename: $!\n");
		local $/;
		<$json_fh>
	};
	# Define image path and image name from JSON filename
	my $image_path = "../" . substr($json_filename, 0, -4) . "png";
	my $image_name = basename("$image_path");
	
	# Parse JSON to get match area infos
	my $json = JSON->new;
	my $data = $json->decode($json_text);
	
	my $areas = $data->{area};
	my $nbAreas = scalar @$areas;
	
	# Generate HTML file from template and JSON infos
	system("mkdir -p ./needles_match_area/");
	my $filename = "./needles_match_area/" . substr($image_name, 0, -3) . "html";

	my $template = Text::Template->new(TYPE => "FILE", SOURCE => $template_filename);
	my $output_file = path("$filename");
	
	my $ctxline = '';
	
	for (my $i = 0; $i < $nbAreas; $i++) {
		my $xpos = $data->{"area"}[$i]->{"xpos"};
		my $ypos = $data->{"area"}[$i]->{"ypos"};
		my $width= $data->{"area"}[$i]->{"width"};
		my $height = $data->{"area"}[$i]->{"height"};
		$ctxline = $ctxline."\n    ctx.rect($xpos, $ypos, $width, $height); "
	}
	my $fragment = $template->fill_in(HASH => {
		image_path => $image_path,
		image_name => $image_name,
		ctxline => "$ctxline"
	});
	$output_file->spew_utf8( $fragment );
}
