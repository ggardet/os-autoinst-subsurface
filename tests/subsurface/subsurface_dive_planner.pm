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
    # Make sure our window is active by clicking inside
    mouse_set(520, 385);
    mouse_click('left');
    
    # Start subsurface dive planner (with Ctrl-L shortcut)
    send_key('ctrl-l');
    
    # Move mouse to get a refresh of the dive profil 'Information' box (at 3:00 of dive, for openSUSE, and 0:40 for Fedora)
    mouse_set(515, 405);
    
    # Check subsurface main screen
    assert_screen 'subsurface-dive-planner-start', 30;
    
    # TODO: play with the dive planner
    sleep 15;
    
    # Click CANCEL button to exit dive planner without saving
    mouse_set(375, 95);
    mouse_click('left');
        
    # Sleep a while to be able to see something on the video
    sleep 15;
        
    # Check subsurface main screen
    assert_screen 'subsurface-main-screen', 30;
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
