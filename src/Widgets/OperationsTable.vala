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

namespace AppViews {
    public class OperationsTable : Gtk.Grid {
        public Gtk.Label title_label;
        public Gtk.Label label;
        public Gtk.TreeView view;

        ArrayList<Operation> operations;

        enum Column {
                DATETIME,
                SOURCE_ASSET,
                SOURCE_QTY,
                DESTINY_ASSET,
                DESTINY_QTY,
                NORMALIZED_QTY
        }

        construct {
            label = new Gtk.Label ("");
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
            attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 1);
            attach (view, 0, 2);
            attach (label, 0, 3);

            var selection = view.get_selection ();
            selection.changed.connect (this.on_changed);
        }

        public void setup_treeview (Gee.ArrayList<Operation> ops) {
            // Update the local representation
            operations = ops;

            var listmodel = new Gtk.ListStore (
                6,
                typeof (string),
                typeof (string),
                typeof (float),
                typeof (string),
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

            /*columns*/
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
                                                    new Gtk.CellRendererText (),
                                                    "text", Column.NORMALIZED_QTY);

            /* Insert the phonebook into the ListStore */
            Gtk.TreeIter iter;
            for (int i = 0; i < operations.size; i++) {
                    listmodel.append (out iter);

                    listmodel.set (
                            iter,
                            Column.DATETIME, operations.get (i).datetime.to_string (),
                            Column.SOURCE_ASSET, operations.get (i).source_asset,
                            Column.SOURCE_QTY, operations.get (i).source_qty,
                            Column.DESTINY_ASSET, operations.get (i).destiny_asset,
                            Column.DESTINY_QTY, operations.get (i).destiny_qty,
                            Column.NORMALIZED_QTY, operations.get (i).normalized_qty
                );
            }
        }
        private void on_changed () {
            // TODO
        }
    }
}
