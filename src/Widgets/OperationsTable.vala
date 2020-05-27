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
    public class OperationsTable : Gtk.Grid {
        public Gtk.Label title_label;

        public Gtk.TreeView view;

        enum Column {
            DATETIME,
            SOURCE_ASSET,
            SOURCE_QTY,
            DESTINY_ASSET,
            DESTINY_QTY,
            NORMALIZED_QTY
        }

        public OperationsTable (ArrayList<Operation> operations) {
            view = new Gtk.TreeView ();
            view.set_reorderable (true);
            view.set_headers_clickable (true);
            this.setup_treeview (operations);

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

        private void setup_treeview (ArrayList<Operation> operations) {
            // Create liststore
            var listmodel = new Gtk.ListStore (
                6,
                typeof (string),
                typeof (string),
                typeof (string),
                typeof (string),
                typeof (string),
                typeof (string)
            );
            view.set_model (listmodel);

            var bold_cell = new Gtk.CellRendererText ();
            /* 'weight' refers to font boldness.
             *  400 is normal.
             *  700 is bold.
             */
            bold_cell.set ("weight_set", true);
            bold_cell.set ("weight", 700);

            var euro_cell = new Gtk.CellRendererText ();
            euro_cell.alignment = Gtk.Alignment.RIGHT;

            // Columns
            view.insert_column_with_attributes (-1, _("Date"),
                                                    new Gtk.CellRendererText (), "text",
                                                    Column.DATETIME);

            view.insert_column_with_attributes (-1, _("Source"),
                                                    bold_cell, "text",
                                                    Column.SOURCE_ASSET);

            view.insert_column_with_attributes (-1, _(" "),
                                                    new Gtk.CellRendererText (),
                                                    "text", Column.SOURCE_QTY);

            view.insert_column_with_attributes (-1, _("Destiny"),
                                                    bold_cell, "text",
                                                    Column.DESTINY_ASSET);

            view.insert_column_with_attributes (-1, _(" "),
                                                    new Gtk.CellRendererText (),
                                                    "text", Column.DESTINY_QTY);

            view.insert_column_with_attributes (-1, _("Value"),
                                                    euro_cell,
                                                    "text", Column.NORMALIZED_QTY);

            // Insert the items into the ListStore
            Gtk.TreeIter iter;
            for (int i = 0; i < operations.size; i++) {
                listmodel.append (out iter);

                string source_qty;
                if (operations.get (i).source_asset.type == _("Currency")) {
                    // Up to 2 decimal values
                    source_qty = AppUtils.format_double_to_string (operations.get (i).source_qty, "%.2f");
                }
                else {
                    // Up to 8 decimal values
                    source_qty = AppUtils.format_double_to_string (operations.get (i).source_qty, "%.8f");
                }

                string destiny_qty;
                if (operations.get (i).destiny_asset.type == _("Currency")) {
                    // Up to 2 decimal values
                    destiny_qty = AppUtils.format_double_to_string (operations.get (i).destiny_qty, "%.2f");
                }
                else {
                    // Up to 8 decimal values
                    destiny_qty = AppUtils.format_double_to_string (operations.get (i).destiny_qty, "%.8f");
                }


                listmodel.set (
                    iter,
                    Column.DATETIME, operations.get (i).datetime.to_string (),
                    Column.SOURCE_ASSET, operations.get (i).source_asset.short_name,
                    Column.SOURCE_QTY, source_qty,
                    Column.DESTINY_ASSET, operations.get (i).destiny_asset.short_name,
                    Column.DESTINY_QTY, destiny_qty,
                    Column.NORMALIZED_QTY, AppUtils.format_double_to_string (operations.get (i).normalized_qty, "%.2f") + " " + "EUR"
                );
            }
        }

        private void on_changed () {
            // TODO
        }
    }
}
