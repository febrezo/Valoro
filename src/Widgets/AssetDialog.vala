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
    public class AssetDialog : Granite.MessageDialog {
    	private string[] categories = {_("Cryptoasset"), _("Currency")};
        private Gtk.Entry name_entry;
        private Gtk.Entry short_name_entry;
        private Gtk.ComboBox category_combobox;
        
        public AssetDialog (Gtk.Window parent) {
            Object (
                primary_text: _("Add new asset"),
                secondary_text: _("Introduce the details of a new asset you want to register."),
                buttons: Gtk.ButtonsType.CANCEL,
                transient_for: parent
            );
        }
        construct {
            this.image_icon = GLib.Icon.new_for_string ("application-vnd.openxmlformats-officedocument.presentationml.presentation");            
                
            var suggested_button = new Gtk.Button.with_label (_("Add"));
            suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            suggested_button.set_sensitive (false);
            this.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

            var ask_for_asset_widget = new Gtk.Grid ();

            // Define objects
            var title_time_label = new Gtk.Label (_("Asset details"));
            title_time_label.halign = Gtk.Align.START;
            title_time_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

            var name_label = new Gtk.Label (_("Name: "));
            name_label.halign = Gtk.Align.END;
            name_entry = new Gtk.Entry ();
            name_entry.set_placeholder_text (_("An asset"));

            var short_name_label = new Gtk.Label (_("Short name: "));
            short_name_label.halign = Gtk.Align.END;
            short_name_entry = new Gtk.Entry ();
            short_name_entry.set_max_length (3);
            short_name_entry.set_placeholder_text (_("XYZ"));

            // Change events added
            name_entry.changed.connect ( () => {
                if (name_entry.get_text () != null && short_name_entry.get_text () != null) {
                    suggested_button.set_sensitive (true);
                }
            });
            short_name_entry.changed.connect ( () => {
                short_name_entry.set_text (short_name_entry.get_text ().up ());
                if (name_entry.get_text () != null && short_name_entry.get_text () != null) {
                    suggested_button.set_sensitive (true);
                }
            });

            // Populate the list: 1 is the number of columns, the second value the type.
            var cat_liststore = new Gtk.ListStore (1, typeof (string));
            
            for (int i= 0; i < categories.length; i++) {
                Gtk.TreeIter iter;
                cat_liststore.append (out iter);
                cat_liststore.set (iter, 0, categories[i]);
            }

            var category_label = new Gtk.Label (_("Category: "));
            category_label.halign = Gtk.Align.END;
            category_combobox = new Gtk.ComboBox.with_model (cat_liststore);

            // Add the cell representation for  the combobox
            var cell = new Gtk.CellRendererText ();
            category_combobox.pack_start (cell, false);
            category_combobox.set_attributes (cell, "text", 0);
            category_combobox.set_active (0);

            // Pack grid elements together together
            ask_for_asset_widget.column_spacing = ask_for_asset_widget.row_spacing = 12;
            ask_for_asset_widget.halign = ask_for_asset_widget.valign = Gtk.Align.CENTER;

            ask_for_asset_widget.attach (title_time_label, 0, 0, 2);
            ask_for_asset_widget.attach (name_label, 0, 1);
            ask_for_asset_widget.attach (name_entry, 1, 1);
            ask_for_asset_widget.attach (short_name_label, 0, 2);
            ask_for_asset_widget.attach (short_name_entry, 1, 2);
            ask_for_asset_widget.attach (category_label, 0, 3);
            ask_for_asset_widget.attach (category_combobox, 1, 3);

            //message_dialog.show_error_details ("The details of a possible error.");
            this.custom_bin.add (ask_for_asset_widget);
            this.show_all ();
        }
        
        public Asset? get_new_asset () {
            if (this.run () == Gtk.ResponseType.ACCEPT) {
                // Grab values
                return new Asset (
                    name_entry.get_text (),
                    short_name_entry.get_text (),
                    categories[category_combobox.get_active ()],
                    0.0,
                    0.0
                );
            }

            return null;
        } 
    }
}
