/*
* Copyright (c) 2020 Félix Brezo (https://felixbrezo.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Félix Breo <felixbrezo@disroot.orgm>
*/

namespace Valoro {
    public class WelcomeView : Gtk.Grid {
        construct {
            var welcome = new Granite.Widgets.Welcome (_("Valoro"), _("Manage and track your cryptoassets"));
            welcome.append ("document-new", _("Create new logbook"), _("Start a new logbook to track your operations"));
            welcome.append ("document-open", _("Open logbook"), _("Work with previously saved logbook files"));
            welcome.append ("info", _("Looking for help?"), _("Get support from online resources"));

            add (welcome);

            welcome.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        try {
                            AppInfo.launch_default_for_uri ("https://valadoc.org/granite/Granite.html", null);
                        } catch (Error e) {
                            warning (e.message);
                        }

                        break;
                    case 1:
                        try {
                            AppInfo.launch_default_for_uri ("https://github.com/elementary/granite", null);
                        } catch (Error e) {
                            warning (e.message);
                        }

                        break;
                    case 2:
                        try {
                            AppInfo.launch_default_for_uri (_("https://github.com/febrezo/valoro/master/doc/support/en/"), null);
                        } catch (Error e) {
                            warning (e.message);
                        }

                        break;
                }
            });

        }
    }
}
