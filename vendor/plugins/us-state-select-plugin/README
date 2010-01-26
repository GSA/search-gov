UsStates
========

From http://svn.techno-weenie.net/projects/plugins/us_states/, updated
to run under rails 2.2.

To select "priority" states that show up at the top of the list, call
like so:

<%= us_state_select 'child', 'state', :priority => %w(TX CA) %> 

To select the way states display option and value:

this (default):
<%= us_state_select 'child', 'state'%> 

will yield this:
<option value="AK">Alaska</option>
______
this:
<%= us_state_select 'child', 'state', :show => :full %> 

will yield this:
<option value="Alaska">Alaska</option>

______
Options are:

:full = <option value="Alaska">Alaska</option>
:full_abb = <option value="AK">Alaska</option>
:abbreviations = <option value="AK">AK</option>
::abb_full_abb = <option value="AK">AK - Alaska</option>