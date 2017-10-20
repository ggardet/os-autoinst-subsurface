#/usr/lib/perl
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
	
	# TODO: handle multi area instead of 1st one only
	my $xpos = $data->{"area"}[0]->{"xpos"} . "\n";
	my $ypos = $data->{"area"}[0]->{"ypos"} . "\n";
	my $width= $data->{"area"}[0]->{"width"} . "\n";
	my $height = $data->{"area"}[0]->{"height"} . "\n";
	
	# Generate HTML file from template and JSON infos
	system("mkdir -p ./needles_match_area/");
	my $filename = "./needles_match_area/" . substr($image_name, 0, -3) . "html";
# 	copy("$template_filename","$filename") or die "Copy failed: $!";
# 	my $file = path($filename);
# 	my $data2 = $file->slurp_utf8;
# 	$data2 =~ s/_IMAGE_PATH_/$image_path/g;
# 	$data2 =~ s/_IMAGE_/$image_name/g;
# 	$data2 =~ s/_X_POS_/$xpos/g;
# 	$data2 =~ s/_Y_POS_/$ypos/g;
# 	$data2 =~ s/_X_SIZE_/$width/g;
# 	$data2 =~ s/_Y_SIZE_/$height/g;
# 	$file->spew_utf8( $data2 );
	my $template = Text::Template->new(TYPE => "FILE", SOURCE => $template_filename);
	my $fragment = $template->fill_in(HASH => {
		image_path => $image_path,
		image_name => $image_name,
		xpos => $xpos,
		ypos => $ypos,
		width => $width,
		height => $height
	});
	my $output_file = path("$filename");
	$output_file->spew_utf8( $fragment );
}
