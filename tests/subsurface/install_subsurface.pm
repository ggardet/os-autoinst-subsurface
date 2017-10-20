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
# with this program; if not, see <http://www.gnu.org/licenses/>.

# use base 'opensusebasetest';
use base 'basetest';
use strict;
use testapi;
# use utils;
# use susedistribution;

sub run {
    # Launch a Konsole as root (xterm is not available on Fedora)
    x11_start_program 'konsole';
    assert_screen 'konsole', 300;
    become_root;
    
    # Stop packagekit
    script_run 'systemctl mask packagekit.service';
    script_run 'systemctl stop packagekit.service';
    
    if( testapi::get_var('DISTRI') eq "opensuse") {
	# TODO: check openSUSE version to select repo on the fly
	# Import GPG key
	assert_script_run 'rpm --import https://download.opensuse.org/repositories/home:/Subsurface-Divelog/openSUSE_Tumbleweed/repodata/repomd.xml.key';
	
	# Install subsurface daily from OBS repo
	assert_script_run 'zypper --non-interactive ar -f https://download.opensuse.org/repositories/home:/Subsurface-Divelog/openSUSE_Tumbleweed/home:Subsurface-Divelog.repo', 300;
	assert_script_run 'zypper --non-interactive install subsurfacedaily', 600;
# 	assert_script_run 'zypper --non-interactive install subsurface', 600;
# 	FIXME: We should use ensure_installed() instead to be generic, but ATM it fails for an unknown reason
#	ensure_installed 'subsurfacedaily';
    }
    elsif(testapi::get_var('DISTRI') eq "fedora") {
	# TODO: check Fedora version to select repo on the fly
	# Import GPG key
	assert_script_run 'rpm --import https://download.opensuse.org/repositories/home:/Subsurface-Divelog/Fedora_26/repodata/repomd.xml.key';
	
	# Install subsurface daily from OBS repo
	assert_script_run 'dnf config-manager --add-repo "https://download.opensuse.org/repositories/home:/Subsurface-Divelog/Fedora_26/home:Subsurface-Divelog.repo"', 300;
	assert_script_run 'yum --assumeyes install subsurfacedaily', 1000; # Some Fedora mirrors are _very_ slow
# 	assert_script_run 'yum --assumeyes install subsurface', 1000; # Some Fedora mirrors are _very_ slow
    }
#     elsif(testapi::get_var('DISTRI') eq "appimage"){
# 	# TODO: test AppImage: https://subsurface-divelog.org/downloads/Subsurface-4.6.4-x86_64.AppImage
#     }
    else {
	# Unsupported DISTRI
	die "Please implement Subsurface installation process for your DISTRI: '".testapi::get_var('DISTRI')."' in install_subsurface.pm file\n";
    }
    
    # Leave root mode
    type_string "exit\n";
    
    # Get subsurface version from binary
    record_info('subsurface_version', script_output('subsurface --version'));
    
    # Close current console window
    type_string "exit\n";
    
    # wait for the desktop to appear again
    assert_screen 'desktop', 300;
}

sub test_flags {
    # 'fatal'          - abort whole test suite if this fails (and set overall state 'failed')
    # 'ignore_failure' - if this module fails, it will not affect the overall result at all
    # 'milestone'      - after this test succeeds, update 'lastgood'
    # 'norollback'     - don't roll back to 'lastgood' snapshot if this fails
    return { fatal => 1 };
}

1;

# vim: set sw=4 et:
