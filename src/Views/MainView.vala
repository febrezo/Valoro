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

using Gee;

using AppUtils;
using AppWidgets;

namespace AppViews {
    public class MainView : Gtk.Frame {
        private Gtk.Stack stack;

        public MainView (ArrayList<Asset> assets, ArrayList<Operation> operations) {
            // Define the stack
            stack = new Gtk.Stack ();
            stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
        
            var asset_panel = new AssetPanel (assets);
            var operations_table = new OperationsTable (operations);

            if (operations.size > 0) {
                stack.add_named (operations_table, _("Lista of operations"));
            } else {
                stack.add_named (
                    new Gtk.Label (_("No operations loaded.")), 
                    _("List of operations")
                );
            }

            // Building the pane
            var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            paned.position = 130;
            paned.pack1 (asset_panel, false, false);
            paned.add2 (stack);

            margin = 24;

            // Empty the element and update
            this.foreach ((element) => this.remove (element));
            add (paned);
        }
    }
}
