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
    # Launch a Konsole (xterm is not available on Fedora)
    x11_start_program 'konsole';
    assert_screen 'konsole', 300;
    
    # Get interesting XML test files for subsurface (test13.xml: GPS location + 3 tank with gas changes, test16.xml: test dive with wide temperatures, test47.xml: simple graph)
    assert_script_run 'mkdir -p ~/.subsurface/';
    assert_script_run 'curl https://raw.githubusercontent.com/Subsurface-divelog/subsurface/master/dives/test13.xml -o ~/.subsurface/test13.xml';
    assert_script_run 'curl https://raw.githubusercontent.com/Subsurface-divelog/subsurface/master/dives/test16.xml -o ~/.subsurface/test16.xml';
    assert_script_run 'curl https://raw.githubusercontent.com/Subsurface-divelog/subsurface/master/dives/test47.xml -o ~/.subsurface/test47.xml';
    
    # Close current console window
    type_string "exit\n";
    
    # Start subsurface
    x11_start_program 'subsurface';
    
    # Check subsurface update screen (only if not latest version installed)
    if( check_screen('subsurface-check-for-updates', 30) ){
	    record_soft_failure("WARNING: we are not testing latest avalaible version!");
	    # Click 'OK' button
	    mouse_set(700, 370);
	    mouse_click('left');
    }
    else {
	    # Move mouse to get the same image
	    mouse_set(700, 370);
    }
    
    # Check subsurface auto update screen (only on 1st subsurface start)
    assert_screen 'subsurface-auto-check-for-updates', 30;
    # Click 'Accept' button
    mouse_set(520, 385);
    mouse_click('left');
    
    # Maximize window
    mouse_set(822, 13);
    mouse_click('left');
    
    # Check subsurface main screen (empty $USER.xml)
    assert_screen 'subsurface-main-screen-nodive', 30;
    
    # Sleep a while to be able to see something on the video
    sleep 15;
    
    # Quit
    send_key('alt-f4');
    
    
    # Start subsurface with the XML test file (test13): not imported
    x11_start_program 'subsurface ~/.subsurface/test13.xml';
    
    if( check_screen('subsurface-warning-old-datafile', 30) ){
	    send_key('ret');
    }
    
    # Check subsurface main screen (test13.xml)
    assert_screen 'subsurface-main-screen-dive-test13', 30;
    
    # Sleep a while to be able to see something on the video
    sleep 15;
    
    # Quit
    send_key('alt-f4');
    
    
    # Start subsurface with the XML test file (test16): not imported
    x11_start_program 'subsurface ~/.subsurface/test16.xml';
    
    if( check_screen('subsurface-warning-old-datafile', 30) ){
	    send_key('ret');
    }
    
    # Check subsurface main screen (test16.xml)
    assert_screen 'subsurface-main-screen-dive-test16', 30;
    
    # Sleep a while to be able to see something on the video
    sleep 15;
    
    # Quit
    send_key('alt-f4');
    
    
    # Start subsurface with the XML test file (test47): NOT imported
    x11_start_program 'subsurface ~/.subsurface/test47.xml';
    
    # Check subsurface main screen (test47.xml)
    assert_screen 'subsurface-main-screen-dive-test47', 30;
    
    # Sleep a while to be able to see something on the video
    sleep 15;
    
    # Quit
    send_key('alt-f4');
    
    
    # Start subsurface with the XML test file (test47): IMPORTED
    x11_start_program 'subsurface --import ~/.subsurface/test47.xml';
    
    # Check subsurface main screen (test47.xml)
    assert_screen 'subsurface-main-screen-dive-test47', 30;
    
    # Sleep a while to be able to see something on the video
    sleep 15;
    
    # Quit
    send_key('alt-f4');
    
    # Discard changes on quit
    assert_screen('subsurface-warning-save-changes', 30);
    mouse_set(581, 377);
    mouse_click('left');
    
    
    # Start subsurface (with empty default $USER.xml file again, to be ready for next test)
    x11_start_program 'subsurface ~/.subsurface/$USER.xml';
    
    # Check subsurface main screen (empty $USER.xml)
    assert_screen 'subsurface-main-screen-nodive', 30;
    
    # Sleep a while to be able to see something on the video
    sleep 15;
    
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
