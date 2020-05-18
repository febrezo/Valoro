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

namespace AppWidgets {
    public class AccountingTable : Gtk.Grid {
        public Gtk.TreeView view;

        enum Column {
            DATETIME,
            ASSET_ID,
            ASSET_UNITS,
            BUYING_PRICE,
            SELLING_PRICE,
            BENEFIT_TOTAL,
            BENEFIT_PERCENTAGE
        }

        public AccountingTable (ArrayList<AccountingEntry> entries) {
            view = new Gtk.TreeView ();
            view.set_reorderable (true);
            view.set_headers_clickable (true);
            this.setup_treeview (entries);

            //var scrolled_view = new Gtk.ScrolledWindow (null, null);
            //scrolled_view.add (view);

            // Package everything
            column_spacing = 12;
            row_spacing = 12;
            halign = Gtk.Align.CENTER;
            attach (view, 0, 1);

            var selection = view.get_selection ();
            selection.changed.connect (this.on_changed);
        }

        private void setup_treeview (ArrayList<AccountingEntry> entries) {
            // Create liststore
            var listmodel = new Gtk.ListStore (
                7,
                typeof (string),
                typeof (string),
                typeof (float),
                typeof (float),
                typeof (float),
                typeof (float),
                typeof (float)
            );
            view.set_model (listmodel);

            var bold_cell = new Gtk.CellRendererText ();

            /* 'weight' refers to font boldness.
             *  400 is normal.
             *  700 is bold.
             */
            bold_cell.set ("weight_set", true);
            bold_cell.set ("weight", 700);

            // Columns
            view.insert_column_with_attributes (-1, _("Date"),
                                                    new Gtk.CellRendererText (),
                                                    "text",
                                                    Column.DATETIME);

            view.insert_column_with_attributes (-1, _("Asset"),
                                                    bold_cell,
                                                    "text",
                                                    Column.ASSET_ID);
                                                    
            view.insert_column_with_attributes (-1, _("Units"),
                                                    new Gtk.CellRendererText (),
                                                    "text",
                                                    Column.BUYING_PRICE);


            view.insert_column_with_attributes (-1, _("Buying price"),
                                                    new Gtk.CellRendererText (),
                                                    "text",
                                                    Column.BUYING_PRICE);

            view.insert_column_with_attributes (-1, _("Selling price "),
                                                    new Gtk.CellRendererText (),
                                                    "text", 
                                                    Column.SELLING_PRICE);

            view.insert_column_with_attributes (-1, _("Benefit"),
                                                    bold_cell, 
                                                    "text",
                                                    Column.BENEFIT_TOTAL);

            view.insert_column_with_attributes (-1, _("%"),
                                                    bold_cell, 
                                                    "text",
                                                    Column.BENEFIT_PERCENTAGE);


            // Insert the items into the ListStore 
            Gtk.TreeIter iter;
            for (int i = 0; i < entries.size; i++) {
                listmodel.append (out iter);

                listmodel.set (
                    iter,
                    Column.DATETIME, entries.get (i).datetime.to_string (),
                    Column.ASSET_ID, entries.get (i).asset_id,
                    Column.ASSET_UNITS, entries.get (i).asset_units,
                    Column.BUYING_PRICE, entries.get (i).buying_price,
                    Column.SELLING_PRICE, entries.get (i).selling_price,
                    Column.BENEFIT_TOTAL, entries.get (i).benefit,
                    Column.BENEFIT_PERCENTAGE, entries.get (i).benefit / entries.get (i).buying_price * 100.0
                );
            }
        }

        private void on_changed () {
            // TODO
        }
    }
}
