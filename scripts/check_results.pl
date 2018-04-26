#!/usr/bin/perl
use strict;
use warnings;
use lib qw(..);
use JSON qw( );
use Path::Tiny qw(path);
use POSIX qw(strftime);
use Term::ANSIColor;
use File::Copy;
use File::stat;
use Time::localtime;
use Time::Piece;
use Switch;
use Text::Template;


# Place here the vars used directly from sub
my $folder = $ARGV[0];

sub print_ok_fail_with_color {
	my $result = $_[0];
	if($result eq "fail"){
		print color('bold red');
		print $result;
	}
	else { # if($result eq "ok"){
		print color('bold green');
		print $result;
	}
	print color('reset');
}

sub generate_html_page_results {
	# Get params: $subsurface_version, $subsurface_full_version, $nb_tests, $nb_passed_tests, $nb_softfail_tests, $nb_fail_tests, $nb_skipped_tests, $linux_name, $linux_version, $output_folder, $epoch_of_test 
	my $subsurface_version=  $_[0];
	my $subsurface_full_version =  $_[1];
	my $nb_tests =  $_[2];
	my $nb_passed_tests =  $_[3];
	my $nb_softfail_tests = $_[4];
	my $nb_fail_tests =  $_[5];
	my $nb_skipped_tests =  $_[6];
	my $linux_name=  $_[7];
	my $linux_version=  $_[8];
	my $output_folder =  $_[9];
	my $epoch_of_test =  $_[10];
	my $date = strftime('%d/%m/%Y %H:%M:%S', gmtime($epoch_of_test));
	# HTML fragment template
	my $template_filename = 'templates/template_results_fragment.html.inc';
	my $output_filename = "$output_folder/$epoch_of_test.html.inc";
	
	# Compute percentages
	my $pc_passed_tests =  $nb_passed_tests / $nb_tests * 100;
	my $pc_softfail_tests =  $nb_softfail_tests / $nb_tests * 100;
	my $pc_fail_tests =  $nb_fail_tests / $nb_tests * 100;
	my $pc_skipped_tests =  $nb_skipped_tests / $nb_tests * 100;
	
	# Generate HTML file from template and results infos
# 	print "Genrating $output_filename\n";
	my $link_to_tests_details = "$output_folder/$epoch_of_test/index.html";
	my $output_file = path("$output_filename");
	my $template = Text::Template->new(TYPE => "FILE", SOURCE => "$template_filename");
	my $fragment = $template->fill_in(HASH => {
		link_to_tests_details => $link_to_tests_details,
		date => $date,
		nb_tests => $nb_tests,
		nb_passed_tests => $nb_passed_tests,
		nb_softfail_tests => $nb_softfail_tests,
		nb_fail_tests => $nb_fail_tests,
		nb_skipped_tests => $nb_skipped_tests,
		pc_passed_tests => $pc_passed_tests,
		pc_softfail_tests => $pc_softfail_tests,
		pc_fail_tests => $pc_fail_tests,
		pc_skipped_tests => $pc_skipped_tests
	});
	$output_file->spew_utf8( $fragment );
	
	# (Re)generate body2 part + fragment files for the given Linux version
	## body2 part
	$output_filename = "$output_folder/../$linux_name $linux_version.html.inc";
	$output_filename =~ s/\ /_/g;
# 	print "Genrating $output_filename\n";
	$output_file = path("$output_filename");
	$template = Text::Template->new(TYPE => "FILE", SOURCE => "templates/template_results_body_2.html.inc");
	$fragment = $template->fill_in(HASH => {
		linux_name => $linux_name,
		linux_version => $linux_version
	});
	$output_file->spew_utf8( "" );
	## test fragments part
	my @fragments = glob $output_folder."/*.html.inc";
	foreach my $test (reverse @fragments) { # Reverse order to get latest test first
		$output_file->append( $fragment );
		my $input_file = path("$test");
		$output_file->append( $input_file->slurp_utf8 );
		$output_file->append( "	</div>" );
	}
	
	# (Re)generate body1 part + body 2 parts the given Subsurface version
	## body1 part
	$output_filename = "$output_folder/../../$subsurface_version.html.inc";
# 	$output_filename =~ s/\ /_/g;
# 	print "Genrating $output_filename\n";
	
	$template = Text::Template->new(TYPE => "FILE", SOURCE => "templates/template_results_body_1.html.inc");
	$fragment = $template->fill_in(HASH => {
		subsurface_version => $subsurface_version,
		subsurface_full_version => $subsurface_full_version
	});
	$output_file = path("$output_filename");
	$output_file->spew_utf8( $fragment );
	## Body 2 parts
	@fragments = glob $output_folder."/../*.html.inc";
	foreach my $test (@fragments) {
		my $input_file = path("$test");
		$output_file->append( $input_file->slurp_utf8 );
	}

	# (Re)generate index.html
	## Header
	$output_filename = "$output_folder/../../index.html";
# 	$output_filename =~ s/\ /_/g;
# 	print "Genrating $output_filename\n";
	copy('templates/template_results_header.html.inc', $output_filename) or die "Copy failed: $!";
	copy('templates/bootstrap.css', "$output_folder/../../bootstrap.css");
	## body1 part
	$output_file = path("$output_filename");
	@fragments = glob $output_folder."/../../*.html.inc";
	foreach my $test (reverse @fragments) {  # Reverse order to get latest version first
		my $input_file = path("$test");
		$output_file->append( $input_file->slurp_utf8 );
	}
	## Footer
	my $input_file = path("templates/template_results_footer.html.inc");
	$output_file->append( $input_file->slurp_utf8 );
	
}

my $num_args = $#ARGV + 1;
if ($num_args != 1) {
	print "Usage: check_results.pl <testresults folder>\n";
	exit;
}
if(! ($0 eq "check_results.pl") ){
	print "Please call the 'check_results.pl' script from its directory\n";
	exit;
}

my $test_order_filename = "$folder/test_order.json";
print "stat($test_order_filename)\n";
my $epoch_of_test = ( stat($test_order_filename)->ctime );
my $subsurface_full_version;
my $subsurface_version;
my $linux_id;
my $linux_name;
my $linux_prettyname;
my $linux_version;



my $json_text = do {
	open(my $json_fh, "<:encoding(UTF-8)", $test_order_filename)
	or die("Can't open $test_order_filename: $!\n");
	local $/;
	<$json_fh>
};

my $json = JSON->new;
my $json_data = $json->decode($json_text);

my $nb_tests = scalar @{$json_data};
my $nb_passed_tests = 0;
my $nb_softfail_tests = 0;
my $nb_fail_tests = 0;
my $nb_skipped_tests = $nb_tests;

# HTML report: details page
## Header
my $HTML_output_filename = "$folder/../index.html";
# $output_filename =~ s/\ /_/g;
# print "Genrating $HTML_output_filename\n";
copy('templates/template_results_details_header.html.inc', $HTML_output_filename) or die "Copy failed: $!";
copy('templates/bootstrap.css', "$folder/../bootstrap.css");
copy('templates/overlay.css', "$folder/../overlay.css");
my $HTML_output_file;

# test_order.json
foreach my $f ( @{$json_data} ) {
	print $f->{"name"} . ":\n";
# 	print $f->{"category"} . "\n";
	print "\tScript: ".$f->{"script"} . "\n";
	my $result_data;
	if($nb_fail_tests == 0){
		
		my $test_result_filename = "$folder/result-".$f->{"name"}.".json";
		
		my $json_result_text = do {
			open(my $json_fh, "<:encoding(UTF-8)", $test_result_filename)
			or die("Can't open $test_result_filename: $!\n");
			local $/;
			<$json_fh>
		};
		
		my $result_json = JSON->new;
		$result_data = $result_json->decode($json_result_text);
		
		# Console output
		print "\tResult: ";
		print_ok_fail_with_color($result_data->{"result"});
		print "\n";	
		print "\tDetails:\n";
		
		# HTML output
		$HTML_output_file = path("$HTML_output_filename");
		my $HTML_input_file = path("templates/template_results_details_testnamepart.html.inc");
		my $test_name = $f->{"name"};
		my $displayed_test_result = $result_data->{"result"};
		switch($displayed_test_result){
			case "ok" 	{ $displayed_test_result = "passed"; }
			case "fail" 	{ $displayed_test_result = "failed"; }
			else 		{ $displayed_test_result = "unknown"; }
		}
		my $result = $result_data->{"result"};
		switch($result){
			case "ok" 	{ $result = "ok"; }
			case "fail" 	{ $result = "failed"; }
			else 		{ $result = "unknown"; }
		}
		my $template = Text::Template->new(TYPE => "FILE", SOURCE => "$HTML_input_file");
		my $fragment = $template->fill_in(HASH => {
			test_name => $test_name,
			displayed_test_result => $displayed_test_result,
			result => $result
		});
		$HTML_output_file->append( $fragment );
		## Prepare for next HTML part
		$HTML_input_file = path("templates/template_results_details_screenshot.html.inc");
		my $HTML_input_file_serial = path("templates/template_results_details_serial.html.inc");
		
		my $details = $result_data->{"details"};
		my $nb_details = scalar @$details;
		
		for (my $i = 0; $i < $nb_details; $i++) {
			if( $result_data->{"details"}[$i]->{"result"} eq "ok" || $result_data->{"details"}[$i]->{"result"} eq "fail" ){
				if($result_data->{"details"}[$i]->{"needle"}){ # We have a matching needle
					# Console
					print "\t\t* Needle: ".$result_data->{"details"}[$i]->{"needle"}."\n";
					print "\t\t  Similarity: ".$result_data->{"details"}[$i]->{"area"}[0]->{"similarity"}."\n";
					print "\t\t  Result: ";
					print_ok_fail_with_color($result_data->{"details"}[$i]->{"area"}[0]->{"result"});
					print "\n";
					# HTML
					my $area_color = 'red';
					if( $result_data->{"details"}[$i]->{"area"}[0]->{"result"} eq "ok" ){
						$area_color = 'yellow';
					}
					$template = Text::Template->new(TYPE => "FILE", SOURCE => "$HTML_input_file");
					$fragment = $template->fill_in(HASH => {
						img_similarity => $result_data->{"details"}[$i]->{"area"}[0]->{"similarity"},
						screenshot => $result_data->{"details"}[$i]->{"screenshot"},
						needle => $result_data->{"details"}[$i]->{"needle"},
						result => $result_data->{"details"}[$i]->{"area"}[0]->{"result"},
						area_color => $area_color,
						area_xpos => $result_data->{"details"}[$i]->{"area"}[0]->{"x"},
						area_ypos => $result_data->{"details"}[$i]->{"area"}[0]->{"y"},
						area_xsize => $result_data->{"details"}[$i]->{"area"}[0]->{"w"},
						area_ysize => $result_data->{"details"}[$i]->{"area"}[0]->{"h"}
					});
					$HTML_output_file->append( $fragment );
				}
				elsif($result_data->{"details"}[$i]->{"title"}){ # We have some infos to extract
					if($result_data->{"details"}[$i]->{"title"} eq "subsurface_version"){
						open(my $fh, '<', "$folder/$result_data->{\"details\"}[$i]->{\"text\"}") or die "cannot open file $folder/$result_data->{\"details\"}[$i]->{\"text\"}";
						{
							local $/;
							$subsurface_full_version = <$fh>;
						}
						close($fh);
					}
					elsif($result_data->{"details"}[$i]->{"title"} =~ "linux_"){
						my $tmp_val;
						open(my $fh, '<', "$folder/$result_data->{\"details\"}[$i]->{\"text\"}") or die "cannot open file $folder/$result_data->{\"details\"}[$i]->{\"text\"}";
						{
							local $/;
							$tmp_val = <$fh>;
						}
						close($fh);
						switch($result_data->{"details"}[$i]->{"title"}){
							case "linux_id" 	{ $linux_id = $tmp_val; }
							case "linux_name" 	{ $linux_name = $tmp_val; }
							case "linux_prettyname" { $linux_prettyname = $tmp_val; }
							case "linux_version" 	{ $linux_version = $tmp_val; }
							else 			{ }
						}
					}
					elsif($result_data->{"details"}[$i]->{"title"} eq "wait_serial"){
						my $file_content = `cat $folder/$result_data->{"details"}[$i]->{"text"}`;
						$file_content =~ s/\n/<br>\n/g;
						# HTML
						$template = Text::Template->new(TYPE => "FILE", SOURCE => "$HTML_input_file_serial");
						$fragment = $template->fill_in(HASH => {
							file => $result_data->{"details"}[$i]->{"text"},
							content => "$file_content",
							result => $result_data->{"details"}[$i]->{"result"}
						});
						$HTML_output_file->append( $fragment );
					}
					print "\t\t* Title: ".$result_data->{"details"}[$i]->{"title"}."\n";
					print "\t\t  Text: ".$result_data->{"details"}[$i]->{"text"}."\n";
					print "\t\t  Result: ";
					print_ok_fail_with_color($result_data->{"details"}[$i]->{"result"});
					print "\n";
				}
				else { 	# We have a failure (no matching needle)
					print "\t\t* Needle: all needles fail for '".$result_data->{"details"}[$i]->{"tags"}[0]."'\n";
					if( $result_data->{"details"}[$i]->{"needles"} ){
						for (my $j = 0; $j < scalar @{$result_data->{"details"}[$i]->{"needles"}}; $j++) {
							print "\t\t\t - Failed needle name: ".$result_data->{"details"}[$i]->{"needles"}[$j]->{"name"}."\n";
							print "\t\t\t   Similarity: ".$result_data->{"details"}[$i]->{"needles"}[$j]->{"area"}[0]->{"similarity"}."\n";
						}
					}
					print "\t\t  Result: ";
					print_ok_fail_with_color($result_data->{"details"}[$i]->{"result"});
					print "\n";
					# HTML
					$template = Text::Template->new(TYPE => "FILE", SOURCE => "$HTML_input_file");
					$fragment = $template->fill_in(HASH => {
						img_similarity => 0,
						screenshot => $result_data->{"details"}[$i]->{"screenshot"},
						needle => "none for '" . $result_data->{"details"}[$i]->{"tags"}[0] ."'",
						result => $result_data->{"details"}[$i]->{"result"},
						area_color => 'grey',
						area_xpos => 0,
						area_ypos => 0,
						area_xsize => 0,
						area_ysize => 0
					});
					$HTML_output_file->append( $fragment );
				}
			}
			elsif ($result_data->{"details"}[$i]->{"result"} eq "unk"){
				# HTML
				my $needle = "none";
				if( $result_data->{"details"}[$i]->{"tags"}[0] ){
					$needle =  "none for '" . $result_data->{"details"}[$i]->{"tags"}[0] ."'";
				}
				$template = Text::Template->new(TYPE => "FILE", SOURCE => "$HTML_input_file");
				$fragment = $template->fill_in(HASH => {
					img_similarity => "unknown",
					screenshot => $result_data->{"details"}[$i]->{"screenshot"},
					needle => $needle,
					result => $result_data->{"details"}[$i]->{"result"},
					area_color => 'grey',
					area_xpos => 0,
					area_ypos => 0,
					area_xsize => 0,
					area_ysize => 0
				});
				$HTML_output_file->append( $fragment );
			}
			elsif($result_data->{"details"}[$i]->{"title"} eq "Soft Failed"){
				$nb_softfail_tests++;
				$nb_tests++; # Add the soft fail test to the list (We are not testing the latest version)
			}
		}
	}
	else { # One test failed
		if($nb_skipped_tests > 0){
			$HTML_output_file = path("$HTML_output_filename");
			my $HTML_input_file = path("templates/template_results_details_testnamepart.html.inc");
			my $template = Text::Template->new(TYPE => "FILE", SOURCE => "$HTML_input_file");
			my $fragment = $template->fill_in(HASH => {
				test_name => $f->{"name"},
				displayed_test_result => "none",
				result => "unknwon"
			});
			$HTML_output_file->append( $fragment );
			# HTML (close row)
			$HTML_input_file = path("templates/template_results_details_testnamepart_close.html.inc");
			$HTML_output_file->append($HTML_input_file->slurp_utf8);
		}
	}

	# Console
	print "\n";
	# HTML (close row)
	my $HTML_input_file = path("templates/template_results_details_testnamepart_close.html.inc");
	$HTML_output_file->append($HTML_input_file->slurp_utf8);
	
	# Until we hit a failed test, manage number of passed/failed/skipped tests
	if($nb_fail_tests == 0){
		if($result_data->{"result"} eq "fail"){
			$nb_fail_tests++;
	# 		$nb_skipped_tests--;
	# 		last;
		}
		else {
			$nb_passed_tests++;
	# 		$nb_skipped_tests--;
		}
		$nb_skipped_tests--;
	}
}

# HTML (end HTML file properly)
my $HTML_input_file = path("templates/template_results_details_footer.html.inc");
$HTML_output_file->append($HTML_input_file->slurp_utf8);

if( defined $subsurface_full_version ){
	$subsurface_version = substr((split ' ', $subsurface_full_version)[1], 0, -1);
	print "Subsurface version: $subsurface_version ($subsurface_full_version)\n";
}
else {
	print "Subsurface version: UNKNOWN\n";
}

print "Linux version: $linux_name $linux_version \n";

print "Tests results overview:\n";
print "\tNumber of tests: $nb_tests\n";
print "\t\t$nb_passed_tests : PASSED\n";
print "\t\t$nb_softfail_tests : SOFTFAILED\n";
print "\t\t$nb_fail_tests : FAILED\n";
print "\t\t$nb_skipped_tests : SKIPPED\n";

if( ! $subsurface_version ){
	print "\nNOT genrating HTML files for this test since we cannot get subsurface version.\n";
}
else {
	# Generate HTML reports
	print "\nGenrating HTML files for this test... ";
	## Generate HTML fragment for this test
	my $output_folder = "../tests_reports/$subsurface_version/$linux_name $linux_version";
	$output_folder =~ s/\ /_/g;
	system("mkdir -p $output_folder");
	# Copy test results to a folder to keep it for futur use (make use of screenshot in HTML pages and more)
	my $testresults_output_folder = "$output_folder/$epoch_of_test";
	system("mkdir -p $testresults_output_folder");
	system("cp -R \"$folder/../\" \"$testresults_output_folder\"");
	# Call main HTML function
	generate_html_page_results($subsurface_version, $subsurface_full_version, $nb_tests, $nb_passed_tests, $nb_softfail_tests, $nb_fail_tests, $nb_skipped_tests, $linux_name, $linux_version, $output_folder, $epoch_of_test);
	
	print "DONE\n";
}
