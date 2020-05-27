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
    enum Column {
        ASSET_NAME
    }

    public class OperationDialog : Granite.MessageDialog {
        private Granite.Widgets.DatePicker date_picker;
        private Granite.Widgets.TimePicker time_picker;
        private Gtk.ComboBox src_asset_combobox;
        private Gtk.SpinButton src_qty_spin;
        private Gtk.ComboBox dst_asset_combobox;
        private Gtk.SpinButton dst_qty_spin;
        private Gtk.SpinButton real_asset_spin;
        public ArrayList<string> string_assets {get; construct set;}
        public HashMap<string, Asset> assets {get; construct set;}

        public OperationDialog (Gtk.Window parent, HashMap<string, Asset> assets) {
            // Prepare the property from the hashmap
            var tmp_array = new ArrayList<string> ();
            foreach (var element in assets.entries) {
                tmp_array.add (element.value.short_name);
            }

            Object (
                primary_text: _("Add new operation"),
                secondary_text: _("Introduce the details of the operation you want to register."),
                buttons: Gtk.ButtonsType.CANCEL,
                transient_for: parent,
                string_assets: tmp_array,
                assets: assets
            );
        }

        construct {
            this.image_icon = GLib.Icon.new_for_string ("event-new");

            // Cell representation for the combobox
            var cell = new Gtk.CellRendererText ();

            // Populate the list of assets
            var asset_liststore = new Gtk.ListStore (1, typeof (string));

            foreach (var asset_short_name in string_assets) {
                Gtk.TreeIter iter;
                asset_liststore.append (out iter);
                asset_liststore.set (iter, Column.ASSET_NAME, asset_short_name);
            }

            var suggested_button = new Gtk.Button.with_label (_("Add"));
            suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            this.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

            var ask_for_info_widget = new Gtk.Grid ();

            // Define objects
            var title_time_label = new Gtk.Label (_("Temporal details"));
            title_time_label.halign = Gtk.Align.START;
            title_time_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

            var date_label = new Gtk.Label (_("Date: "));
            date_label.halign = Gtk.Align.END;
            date_picker = new Granite.Widgets.DatePicker ();

            var time_label = new Gtk.Label (_("Time: "));
            time_label.halign = Gtk.Align.END;
            time_picker = new Granite.Widgets.TimePicker ();

            var title_source_label = new Gtk.Label (_("Source"));
            title_source_label.halign = Gtk.Align.START;
            title_source_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

            var source_asset_label = new Gtk.Label (_("Asset: "));
            source_asset_label.halign = Gtk.Align.END;
            src_asset_combobox = new Gtk.ComboBox.with_model (asset_liststore);
            src_asset_combobox.set_active (0);
            // Add the cell representation for  the combobox
            src_asset_combobox.pack_start (cell, false);
            src_asset_combobox.set_attributes (cell, "text", 0);

            var source_qty_label = new Gtk.Label (_("Quantity: "));
            source_qty_label.halign = Gtk.Align.END;
            src_qty_spin = new Gtk.SpinButton.with_range (0, 100000000, 0.00000001);

            var title_destiny_label = new Gtk.Label (_("Destiny"));
            title_destiny_label.halign = Gtk.Align.START;
            title_destiny_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

            var destiny_asset_label = new Gtk.Label (_("Asset: "));
            destiny_asset_label.halign = Gtk.Align.END;
            dst_asset_combobox = new Gtk.ComboBox.with_model (asset_liststore);
            dst_asset_combobox.set_active (0);
            // Add the cell representation for  the combobox
            dst_asset_combobox.pack_start (cell, false);
            dst_asset_combobox.set_attributes (cell, "text", 0);

            var destiny_qty_label = new Gtk.Label (_("Quantity: "));
            destiny_qty_label.halign = Gtk.Align.END;
            dst_qty_spin = new Gtk.SpinButton.with_range (0, 100000000, 0.00000001);

            var real_asset_label = new Gtk.Label (_("Asset real value: "));
            real_asset_label.halign = Gtk.Align.END;
            real_asset_spin = new Gtk.SpinButton.with_range (0, 100000000, 0.01);
            real_asset_spin.set_sensitive (false);

            // Pack grid elements together together
            ask_for_info_widget.column_spacing = ask_for_info_widget.row_spacing = 12;
            ask_for_info_widget.halign = ask_for_info_widget.valign = Gtk.Align.CENTER;

            ask_for_info_widget.attach (title_time_label, 0, 0, 2);
            ask_for_info_widget.attach (date_label, 0, 1);
            ask_for_info_widget.attach (date_picker, 1, 1);
            ask_for_info_widget.attach (time_label, 0, 2);
            ask_for_info_widget.attach (time_picker, 1, 2);

            ask_for_info_widget.attach (title_source_label, 0, 3, 2);
            ask_for_info_widget.attach (source_asset_label, 0, 4);
            ask_for_info_widget.attach (src_asset_combobox, 1, 4);
            ask_for_info_widget.attach (source_qty_label, 0, 5);
            ask_for_info_widget.attach (src_qty_spin, 1, 5);

            ask_for_info_widget.attach (title_destiny_label, 0, 6, 2);
            ask_for_info_widget.attach (destiny_asset_label, 0, 7);
            ask_for_info_widget.attach (dst_asset_combobox, 1, 7);
            ask_for_info_widget.attach (destiny_qty_label, 0, 8);
            ask_for_info_widget.attach (dst_qty_spin, 1, 8);
            ask_for_info_widget.attach (real_asset_label, 0, 9);
            ask_for_info_widget.attach (real_asset_spin, 1, 9);

            // Manage events linked to the combobox
            src_asset_combobox.changed.connect (on_comboboxes_change);
            src_qty_spin.value_changed.connect (on_comboboxes_change);
            dst_asset_combobox.changed.connect (on_comboboxes_change);
            dst_qty_spin.value_changed.connect (on_comboboxes_change);

            custom_bin.add (ask_for_info_widget);
            this.show_all ();
        }

        public Operation? get_new_operation () {
            if (this.run () == Gtk.ResponseType.ACCEPT) {
                // Auxiliar information
                var dst_active_asset_name = string_assets.get (dst_asset_combobox.get_active ());
                var src_active_asset_name = string_assets.get (src_asset_combobox.get_active ());

                var provided_date = new GLib.DateTime (
                    new TimeZone.local (),
                    date_picker.date.get_year (),
                    date_picker.date.get_month (),
                    date_picker.date.get_day_of_month (),
                    time_picker.time.get_hour (),
                    time_picker.time.get_minute (),
                    time_picker.time.get_seconds ()
                );

                // Grab values
                return new Operation (
		                provided_date,
                    assets[src_active_asset_name],
                    src_qty_spin.get_value (),
                    assets[dst_active_asset_name],
                    dst_qty_spin.get_value (),
                    real_asset_spin.get_value ()
                );
            }
            return null;
        }

        private void on_comboboxes_change () {
            var src_active_asset_name = string_assets.get (src_asset_combobox.get_active ());
            var dst_active_asset_name = string_assets.get (dst_asset_combobox.get_active ());

            // TODO: Change "EUR" by any default asset
            if (src_active_asset_name != "EUR") {
                if (dst_active_asset_name != "EUR") {
                    real_asset_spin.set_sensitive (true);
                } else {
                    real_asset_spin.set_value (dst_qty_spin.get_value ());
                    real_asset_spin.set_sensitive (false);
                }
            } else if (dst_active_asset_name != "EUR") {
                real_asset_spin.set_value (src_qty_spin.get_value ());
                real_asset_spin.set_sensitive (false);
            } else {
                real_asset_spin.set_sensitive (true);
            }
        }
    }
}
