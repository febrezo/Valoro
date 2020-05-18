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
        private OperationsTable operations_table;
        private AccountingTable accounting_table;
        
        public MainView (ArrayList<Asset> assets, ArrayList<Operation> operations, ArrayList<AccountingEntry> entries) {
            // Creating the main widgets
            // -------------------------
            
            // Create the left pane
            asset_panel = new AssetPanel (assets);
            
            // Create the operation table
            operations_table = new OperationsTable (operations);
            
            // Create accounting table
            accounting_table = new AccountingTable (entries);
            
            build_ui ();
        }
        
        public void update_data (ArrayList<Asset> assets, ArrayList<Operation> operations, ArrayList<AccountingEntry> entries) {
            // Cleaning previous elements
            this.foreach ((element) => {this.remove (element);});
            
            // Create the left pane
            asset_panel = new AssetPanel (assets);
            
            // Create the operation table
            operations_table = new OperationsTable (operations);
            
            // Create accounting table
            accounting_table = new AccountingTable (entries);
            
            build_ui ();
        }
        
        private void build_ui () {
            // Packaging things
            var operations_page = new Gtk.Grid ();
            operations_page.add (operations_table);
            
            var accounting_page = new Gtk.Grid ();
            accounting_page.add (accounting_table);

            // Organizing the stack
            // --------------------
            var stack = new Gtk.Stack ();
            stack.expand = true;
            stack.homogeneous = true;
            stack.halign = Gtk.Align.CENTER;
            stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
            stack.set_transition_duration (1000);

            // Pack stack tabs
            stack.add_titled (
                operations_page,
                "operations",
                _("Operations list")
            );
            stack.add_titled (
                accounting_page,
                "accounting",
                _("Accounting")
            );
            
            // Link menus and stack
            var stack_switcher = new Gtk.StackSwitcher ();
            stack_switcher.stack = stack;
            stack_switcher.halign = Gtk.Align.CENTER;
            
            var stack_grid = new Gtk.Grid ();
            stack_grid.column_spacing = 12;
            stack_grid.row_spacing = 12;
            stack_grid.halign = Gtk.Align.CENTER;
            stack_grid.attach (stack_switcher, 0, 0);
            stack_grid.attach (stack, 0, 1);
            
            // Building the pane
            // -----------------
            var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            paned.position = 200;
            paned.pack1 (asset_panel, true, false);
            paned.add2 (stack_grid);
            
            add (paned);
            margin = 36;
            this.show_all ();
        }
    }
}
