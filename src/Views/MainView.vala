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
		private AssetPanel asset_panel;
		private Granite.Widgets.SourceList.ExpandableItem currency_category;
		private Granite.Widgets.SourceList.ExpandableItem cryptoasset_category;

		private Gtk.Stack stack;
		private OperationsTable operations_table;
		private Gtk.Label message_label;

		construct {
				// Define the stack
				stack = new Gtk.Stack ();
				stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
				
				// Main widgets
				operations_table = new OperationsTable ();
				asset_panel = new AssetPanel ();
				message_label = new Gtk.Label (_("No operations loaded."));

		    /*asset_panel.item_selected.connect ((item) => {
		        if (item == null) {
		            label.label = "No selected item";
		            return;
		        }

		        /*if (item.badge != "" && item.badge != null) {
		            item.badge = "";
		        }

		        label.label = "%s - %s".printf (item.parent.name, item.name);
		    });*/
		}

		// Actions
		// =======
		public void update_data (ArrayList<Asset> assets, ArrayList<Operation> operations) {
				asset_panel.update_asset_list (assets);
				operations_table.setup_treeview (operations);

				if (operations.size > 0) {
						stack.add_named (operations_table, _("Lista of operations"));
				} else {
						stack.add_named (message_label, _("List of operations"));
				}

				// Building the pane
		    var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
		    paned.position = 130;
		    paned.pack1 (asset_panel, false, false);
		    paned.add2 (stack);

		    margin = 24;
		    add (paned);
		}
	}
}
