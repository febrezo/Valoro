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
using AppViews;
using AppWidgets;

namespace Valoro {
    public class Window : Gtk.ApplicationWindow {
        // Attributes
        // ==========
        private string file_path;
        ArrayList<Operation> operations;
        ArrayList<Asset> assets;

        // Window elements
        private HeaderBar header_bar;
        private Granite.Widgets.Toast toast;
        
        // Views
        private MainView main_view;
        private WelcomeView welcome_view;

        enum Column {
            ASSET_NAME,
            CATEGORY_NAME
        }

        // Methods
        // =======
        /// Tie to the Main Window to the Application
        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            // Set Windows defaults
            // --------------------
            this.default_height = 600;
            this.default_width = 800;
            this.header_bar = new HeaderBar ();

            // Define views
            // ------------
            welcome_view = new WelcomeView ();

            // Define header events
            // --------------------
            this.header_bar.add_asset_btn.clicked.connect (on_add_asset_clicked);
            this.header_bar.add_operation_btn.clicked.connect (on_add_operation_clicked);
            this.header_bar.new_btn.clicked.connect (on_new_clicked);
            this.header_bar.open_btn.clicked.connect (on_open_clicked);
            this.header_bar.settings_menu_btn.clicked.connect (on_menu_clicked);

            // Pack things
            // -----------
            this.set_titlebar(header_bar);
            this.add (welcome_view);
        }

        // Events
        // ======
        private void on_new_clicked () {
            this.header_bar.subtitle = _("Untitled book.json");

            // Create a new empty currency
            var euro = new Asset ("Euro", "EUR", _("Currency"), 0.0, 0.0);
            assets.add (euro);

            // Activate save, export and new operation buttons
            this.header_bar.save_btn.set_sensitive (true);
            this.header_bar.add_operation_btn.set_sensitive (true);
            this.header_bar.add_asset_btn.set_sensitive (true);
        }

        private void on_open_clicked () {
            var dialog = new Gtk.FileChooserDialog (
                _("Open logbook file"), // Title
                this, // Parent Window
                Gtk.FileChooserAction.OPEN, // Action: OPEN, SAVE, CREATE_FOLDER, SELECT_FOLDER
                _("Cancel"),
                Gtk.ResponseType.CANCEL,
                _("Open"),
                Gtk.ResponseType.ACCEPT
            );

            var res = dialog.run ();

            if (res == Gtk.ResponseType.ACCEPT) {
                var path = dialog.get_filename ();

                // Parse the sample file
                try {
                    var parser = new Json.Parser ();
                    parser.load_from_file (path);

                    var root_object = parser.get_root ().get_object ();

                    // Reinitialize the assets
                    assets = new Gee.ArrayList<Asset> ();

                    // Get list of Json.Node members
                    var assets_list = root_object.get_array_member  ("assets");

                    foreach (var node in assets_list.get_elements ()) {
                        // Retrieve the object from the node
                        var asset_object = node.get_object ();

                        // Grab values
                        var tmp_asset = new Asset (
                            asset_object.get_string_member ("name"),
                            asset_object.get_string_member ("short_name"),
                            asset_object.get_string_member ("type"),
                            asset_object.get_double_member ("units"),
                            asset_object.get_double_member ("average_price")
                        );

                        assets.add (tmp_asset);
                    }

                    // Initialize operations
                    operations = new Gee.ArrayList<Operation> ();

                    // Get operations
                    var operations_array = root_object.get_array_member  ("operations");

                    foreach (var node in operations_array.get_elements ()) {
                        // Retrieve the object from the node
                        var operation_object = node.get_object ();

                        try {
                            // Grab values
                            var datetime = operation_object.get_string_member ("datetime");
                            var source_asset = operation_object.get_string_member ("source_asset");
                            var source_qty = operation_object.get_double_member ("source_qty");
                            var destiny_asset = operation_object.get_string_member ("destiny_asset");
                            var destiny_qty = operation_object.get_double_member ("destiny_qty");
                            var normalized_value = operation_object.get_double_member ("normalized_qty");

                            var tmp_operation = new Operation.from_datetime_string (
                                datetime,
                                source_asset, source_qty,
                                destiny_asset, destiny_qty,
                                normalized_value
                            );

                            operations.add (tmp_operation);
                        } catch (OperationCorrupted.CODE_01 e) {
                            stderr.printf ("[*] Something happened when parsing an operation.\n");
                        }
                    }

                    // Notify correctly the reading of the file
                    this.file_path = path;
                    header_bar.subtitle = this.file_path;
                    toast.title = "%s assets and %s operations parsed.".printf (
                        assets.size.to_string (),
                        operations.size.to_string ()
                    );
                    toast.send_notification ();

                    main_view.show_all ();
                } catch (Error e) {
                    stderr.printf ("[*] Something happened with the JSON Parser...\n");
                    toast.title = _("Could not parse the file. '%s' is corrupted. Have you edited it manually?").printf (path);
                    toast.send_notification ();
                }
            }
            dialog.close ();

            update_main_view ();

            // Activate buttons
            this.header_bar.add_asset_btn.set_sensitive (true);
            this.header_bar.add_operation_btn.set_sensitive (true);
        }

        private void on_save_clicked () {
            // Start a Generator and setup some fields for it
            var base_obj = new Json.Object();

            // Create array of assets
            var assets_array = new Json.Array();
            foreach(Asset a in assets) {
                var json_asset = new Json.Object();
                json_asset.set_string_member("name", a.name);
                json_asset.set_string_member("short_name", a.short_name);
                json_asset.set_string_member("type", a.type);
                json_asset.set_double_member("units", a.units);
                json_asset.set_double_member("average_price", a.average_price);

                assets_array.add_object_element(json_asset);
            }

            // Create array of operations
            var operations_array = new Json.Array();
            foreach (Operation op in operations) {
                var json_op = new Json.Object();
                json_op.set_string_member("datetime", op.datetime.to_string ());
                json_op.set_string_member("source_asset", op.source_asset);
                json_op.set_double_member("source_qty", op.source_qty);
                json_op.set_string_member("destiny_asset", op.destiny_asset);
                json_op.set_double_member("destiny_qty", op.destiny_qty);
                json_op.set_double_member("normalized_qty", op.normalized_qty);

                operations_array.add_object_element(json_op);
            }

            // Add arrays to the base object
            base_obj.set_array_member("assets", assets_array);
            base_obj.set_array_member("operations", operations_array);

            // Generate the Json
            var root = new Json.Node (Json.NodeType.OBJECT);
            root.set_object (base_obj);

            var gen = new Json.Generator ();
            gen.set_root (root);

            print (gen.to_data (null));

            if (this.file_path != null) {
                FileUtils.set_contents (this.file_path, gen.to_data (null));
                this.header_bar.subtitle = this.file_path;

                toast.title = _("File saved: '%s'");
                toast.send_notification ();
            } else {
                var dialog = new Gtk.FileChooserDialog (
                    _("Save logbook"),
                    this,
                    Gtk.FileChooserAction.SAVE,
                    _("Cancel"),
                    Gtk.ResponseType.CANCEL,
                    _("Save"),
                    Gtk.ResponseType.ACCEPT
                );
                var res = dialog.run ();
                dialog.close ();

                if (res == Gtk.ResponseType.ACCEPT) {
                    this.file_path = dialog.get_filename ();

                    FileUtils.set_contents (this.file_path, gen.to_data (null));
                    this.header_bar.subtitle = this.file_path;

                    toast.title = _("File saved: '%s'");
                    toast.send_notification ();
                }
            }

            // Deactivate save, export and new operation buttons
            this.header_bar.save_btn.set_sensitive (false);
        }

        private void on_add_operation_clicked () {
            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                _("Add new operation"),
                _("Introduce the details of the operation you want to register."),
                "event-new",
                Gtk.ButtonsType.CANCEL
            );

            // Populate the list of assets
            Gtk.ListStore asset_liststore = new Gtk.ListStore (1, typeof (string));
            foreach (Asset asset in assets){
                Gtk.TreeIter iter;
                asset_liststore.append (out iter);
                asset_liststore.set (iter, Column.ASSET_NAME, asset.short_name);
            }

            message_dialog.transient_for = this;

            var suggested_button = new Gtk.Button.with_label (_("Add"));
            suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

            var ask_for_info_widget = new Gtk.Grid ();

            // Define objects
            var title_time_label = new Gtk.Label (_("Temporal details"));
            title_time_label.halign = Gtk.Align.START;
            title_time_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

            var date_label = new Gtk.Label (_("Date: "));
            date_label.halign = Gtk.Align.END;
            var date_picker = new Granite.Widgets.DatePicker ();

            var time_label = new Gtk.Label (_("Time: "));
            time_label.halign = Gtk.Align.END;
            var time_picker = new Granite.Widgets.TimePicker ();

            var title_source_label = new Gtk.Label (_("Source"));
            title_source_label.halign = Gtk.Align.START;
            title_source_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

            var source_asset_label = new Gtk.Label (_("Asset: "));
            source_asset_label.halign = Gtk.Align.END;
            var source_asset_combobox = new Gtk.ComboBox.with_model (asset_liststore);
            source_asset_combobox.set_active (0);

            var source_qty_label = new Gtk.Label (_("Quantity: "));
            source_qty_label.halign = Gtk.Align.END;
            var source_qty_spin = new Gtk.SpinButton.with_range (0, 100000000, 0.00000001);

            var title_destiny_label = new Gtk.Label (_("Destiny"));
            title_destiny_label.halign = Gtk.Align.START;
            title_destiny_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

            var destiny_asset_label = new Gtk.Label (_("Asset: "));
            destiny_asset_label.halign = Gtk.Align.END;
            var destiny_asset_combobox = new Gtk.ComboBox.with_model (asset_liststore);
            destiny_asset_combobox.set_active (0);

            var destiny_qty_label = new Gtk.Label (_("Quantity: "));
            destiny_qty_label.halign = Gtk.Align.END;
            var destiny_qty_spin = new Gtk.SpinButton.with_range (0, 100000000, 0.00000001);

            var real_asset_label = new Gtk.Label (_("Asset real value: "));
            real_asset_label.halign = Gtk.Align.END;
            var real_asset_spin = new Gtk.SpinButton.with_range (0, 100000000, 0.01);
            real_asset_spin.set_sensitive (false);

            // Manage events linked to the combobox
            source_asset_combobox.changed.connect ( () => {
                var src_active_asset = assets.get (source_asset_combobox.get_active ());
                var dst_active_asset = assets.get (destiny_asset_combobox.get_active ());

                if (src_active_asset.short_name != "EUR") {
                    if (dst_active_asset.short_name != "EUR") {
                        real_asset_spin.set_sensitive (true);
                    } else {
                        real_asset_spin.set_value (destiny_qty_spin.get_value ());
                        real_asset_spin.set_sensitive (false);
                    }
                } else if (dst_active_asset.short_name != "EUR") {
                    real_asset_spin.set_value (source_qty_spin.get_value ());
                    real_asset_spin.set_sensitive (false);
                } else {
                    real_asset_spin.set_sensitive (true);
                }
            });
            destiny_asset_combobox.changed.connect ( () => {
                var src_active_asset = assets.get (source_asset_combobox.get_active ());
                var dst_active_asset = assets.get (destiny_asset_combobox.get_active ());

                if (src_active_asset.short_name != "EUR") {
                    if (dst_active_asset.short_name != "EUR") {
                        real_asset_spin.set_sensitive (true);
                    } else {
                        real_asset_spin.set_value (destiny_qty_spin.get_value ());
                        real_asset_spin.set_sensitive (false);
                    }
                } else if (dst_active_asset.short_name != "EUR") {
                    real_asset_spin.set_value (source_qty_spin.get_value ());
                    real_asset_spin.set_sensitive (false);
                } else {
                    real_asset_spin.set_sensitive (true);
                }
            });

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
            ask_for_info_widget.attach (source_asset_combobox, 1, 4);
            ask_for_info_widget.attach (source_qty_label, 0, 5);
            ask_for_info_widget.attach (source_qty_spin, 1, 5);

            ask_for_info_widget.attach (title_destiny_label, 0, 6, 2);
            ask_for_info_widget.attach (destiny_asset_label, 0, 7);
            ask_for_info_widget.attach (destiny_asset_combobox, 1, 7);
            ask_for_info_widget.attach (destiny_qty_label, 0, 8);
            ask_for_info_widget.attach (destiny_qty_spin, 1, 8);
            ask_for_info_widget.attach (real_asset_label, 0, 9);
            ask_for_info_widget.attach (real_asset_spin, 1, 9);

            //message_dialog.show_error_details ("The details of a possible error.");
            message_dialog.custom_bin.add (ask_for_info_widget);
            message_dialog.show_all ();

            if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                toast.title = _("New operation added.");
                toast.send_notification ();
            }

            message_dialog.destroy ();
        }

        private void on_add_asset_clicked () {
            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                _("Add new asset"),
                _("Introduce the details of a new asset you want to register."),
                "application-vnd.openxmlformats-officedocument.presentationml.presentation",
                Gtk.ButtonsType.CANCEL
            );

            message_dialog.transient_for = this;

            var suggested_button = new Gtk.Button.with_label (_("Add"));
            suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            suggested_button.set_sensitive (false);
            message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

            var ask_for_asset_widget = new Gtk.Grid ();

            // Define objects
            var title_time_label = new Gtk.Label (_("Asset details"));
            title_time_label.halign = Gtk.Align.START;
            title_time_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

            var name_label = new Gtk.Label (_("Name: "));
            name_label.halign = Gtk.Align.END;
            var name_text = new Gtk.Entry ();
            name_text.set_placeholder_text (_("An asset"));

            var short_name_label = new Gtk.Label (_("Short name: "));
            short_name_label.halign = Gtk.Align.END;
            var short_name_text = new Gtk.Entry ();
            short_name_text.set_max_length (3);
            short_name_text.set_placeholder_text (_("XYZ"));

            // Change events added
            name_text.changed.connect ( () => {
                if (name_text.get_text () != null && short_name_text.get_text () != null) {
                    suggested_button.set_sensitive (true);
                }
            });
            short_name_text.changed.connect ( () => {
                if (name_text.get_text () != null && short_name_text.get_text () != null) {
                    suggested_button.set_sensitive (true);
                }
            });

            // Populate the list: 1 is the number of columns, the second value the type.
            var cat_liststore = new Gtk.ListStore (1, typeof (string));
            Gtk.TreeIter iter;
            cat_liststore.append (out iter);
            cat_liststore.set (iter, 0, _("Currency"));
            cat_liststore.append (out iter);
            cat_liststore.set (iter, 0, _("Cryptoasset"));

            var category_label = new Gtk.Label (_("Category: "));
            category_label.halign = Gtk.Align.END;
            var category_combobox = new Gtk.ComboBox.with_model (cat_liststore);

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
            ask_for_asset_widget.attach (name_text, 1, 1);
            ask_for_asset_widget.attach (short_name_label, 0, 2);
            ask_for_asset_widget.attach (short_name_text, 1, 2);
            ask_for_asset_widget.attach (category_label, 0, 3);
            ask_for_asset_widget.attach (category_combobox, 1, 3);

            //message_dialog.show_error_details ("The details of a possible error.");
            message_dialog.custom_bin.add (ask_for_asset_widget);
            message_dialog.show_all ();

            if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                // Grab values
                var new_asset = new Asset (
                    name_text.get_text (),
                    short_name_text.get_text (),
                    _("Currency"),
                    0.0,
                    0.0
                );
                assets.add (new_asset);

                toast.title = _("New asset added.");
                toast.send_notification ();
            }

            update_main_view ();

            message_dialog.destroy ();
        }

        private void on_menu_clicked (Gtk.Button sender) {
            this.header_bar.menu.set_relative_to (sender);
            this.header_bar.menu.show_all ();
        }

        private void update_main_view () {
            // Remove elements
            this.foreach ((element) => {this.remove (element);});

            // Call _deploy_main_layout with some data
            var main_view = new MainView (assets, operations);

            // Create overlay
            var overlay_panel = new Gtk.Overlay ();
            overlay_panel.add_overlay (main_view);
            overlay_panel.add_overlay (toast);

            this.add (overlay_panel);
        }
    }
}
