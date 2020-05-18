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
        
        public OperationDialog (Gtk.Window parent) {
            Object (
                primary_text: _("Add new operation"),
                secondary_text: _("Introduce the details of the operation you want to register."),
                buttons: Gtk.ButtonsType.CANCEL,
                transient_for: parent
            );    
        } 
        
        construct {
            this.image_icon = GLib.Icon.new_for_string ("event-new");

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
            
            var source_qty_label = new Gtk.Label (_("Quantity: "));
            source_qty_label.halign = Gtk.Align.END;
            src_qty_spin = new Gtk.SpinButton.with_range (0, 100000000, 0.00000001);

            var title_destiny_label = new Gtk.Label (_("Destiny"));
            title_destiny_label.halign = Gtk.Align.START;
            title_destiny_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

            var destiny_asset_label = new Gtk.Label (_("Asset: "));
            destiny_asset_label.halign = Gtk.Align.END;


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

            this.custom_bin.add (ask_for_info_widget);
            this.show_all ();
        }

        private void prepare_comboboxes (Gee.ArrayList<Asset> assets) {
            // Populate the list of assets
            Gtk.ListStore asset_liststore = new Gtk.ListStore (1, typeof (string));
            foreach (Asset asset in assets){
                Gtk.TreeIter iter;
                asset_liststore.append (out iter);
                asset_liststore.set (iter, Column.ASSET_NAME, asset.short_name);
            }
            
            src_asset_combobox = new Gtk.ComboBox.with_model (asset_liststore);
            src_asset_combobox.set_active (0);
            dst_asset_combobox = new Gtk.ComboBox.with_model (asset_liststore);
            dst_asset_combobox.set_active (0);
                        
            // Manage events linked to the combobox
            src_asset_combobox.changed.connect ( () => {
                var src_active_asset = assets.get (src_asset_combobox.get_active ());
                var dst_active_asset = assets.get (dst_asset_combobox.get_active ());

                if (src_active_asset.short_name != "EUR") {
                    if (dst_active_asset.short_name != "EUR") {
                        real_asset_spin.set_sensitive (true);
                    } else {
                        real_asset_spin.set_value (dst_qty_spin.get_value ());
                        real_asset_spin.set_sensitive (false);
                    }
                } else if (dst_active_asset.short_name != "EUR") {
                    real_asset_spin.set_value (src_qty_spin.get_value ());
                    real_asset_spin.set_sensitive (false);
                } else {
                    real_asset_spin.set_sensitive (true);
                }
            });
            
            dst_asset_combobox.changed.connect ( () => {
                var src_active_asset = assets.get (src_asset_combobox.get_active ());
                var dst_active_asset = assets.get (dst_asset_combobox.get_active ());

                if (src_active_asset.short_name != "EUR") {
                    if (dst_active_asset.short_name != "EUR") {
                        real_asset_spin.set_sensitive (true);
                    } else {
                        real_asset_spin.set_value (dst_qty_spin.get_value ());
                        real_asset_spin.set_sensitive (false);
                    }
                } else if (dst_active_asset.short_name != "EUR") {
                    real_asset_spin.set_value (src_qty_spin.get_value ());
                    real_asset_spin.set_sensitive (false);
                } else {
                    real_asset_spin.set_sensitive (true);
                }
            });
        }
        
        public Operation? get_new_operation (Gee.ArrayList<Asset> assets) {
            prepare_comboboxes (assets);
            
            if (this.run () == Gtk.ResponseType.ACCEPT) {
                var src_active_asset = assets.get (src_asset_combobox.get_active ());
                var dst_active_asset = assets.get (dst_asset_combobox.get_active ());
                
                // Grab values
                return new Operation.from_splitted_datetime_string (
		            date_picker.format,
		            time_picker.format_24,
                    src_active_asset.short_name,
                    src_qty_spin.get_value (),
                    dst_active_asset.short_name,
                    dst_qty_spin.get_value (),
                    real_asset_spin.get_value ()
                );
            }

            return null;
        } 
    }
}
