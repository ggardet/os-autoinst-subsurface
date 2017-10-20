# Copyright (C) 2014 SUSE Linux GmbH
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use testapi;
use autotest;

my $distri_varjson = testapi::get_var('DISTRI');

if("$distri_varjson" eq "fedora"){
	# Fedora implementations of expected methods
	my $distri = testapi::get_required_var('CASEDIR') . '/lib/fedoradistribution.pm';
	require $distri;
	testapi::set_distribution(fedoradistribution->new());
}
elsif ("$distri_varjson" eq "opensuse"){
	# openSUSE implementations of expected methods
	my $distri = testapi::get_required_var('CASEDIR') . '/lib/susedistribution.pm';
	require $distri;
	testapi::set_distribution(susedistribution->new());
}
else {
	die "Please define a valid DISTRI in your vars.json";
}


# Test subsurface daily
autotest::loadtest "tests/subsurface/boot.pm";
autotest::loadtest "tests/subsurface/install_subsurface.pm";
autotest::loadtest "tests/subsurface/start_subsurface.pm";
autotest::loadtest "tests/subsurface/subsurface_dive_planner.pm";

1;

# vim: set sw=4 et:
