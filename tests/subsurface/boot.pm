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

use base 'basetest';
use strict;
use testapi;

sub run {
    # wait for bootloader to appear
    assert_screen 'bootloader';

    # press enter to boot right away
    send_key 'ret';

    # wait for the desktop to appear
    assert_screen 'desktop', 300;
    
    # Launch a Konsole (xterm is not available on Fedora)
    x11_start_program 'konsole';
    assert_screen 'konsole', 300;
    become_root;
    
    # Workaround for next tests run as a normal user (start subsurface, and others)
    assert_script_run "chmod 666 /dev/$serialdev";
    
    # Leave root mode
    type_string "exit\n";
    
    # Get Linux name and version (can be useful for test reports)
    record_info('linux_id', script_output('source /etc/os-release && echo $ID')); 	# fedora / opensuse
    record_info('linux_name', script_output('source /etc/os-release && echo $NAME'));	# Fedora / openSUSE Leap / openSUSE Tumbleweed
    record_info('linux_version', script_output('source /etc/os-release && echo $VERSION_ID')); 		# 26 / 42.3 / 20171001 / ...
    record_info('linux_prettyname', script_output('source /etc/os-release && echo $PRETTY_NAME')); 	# Fedora 26 (Twenty Six) / openSUSE Leap 42.3 / openSUSE Tumbleweed
    
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
