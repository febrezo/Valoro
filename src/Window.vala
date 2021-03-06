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
        HashMap<string, Asset> assets;
        ArrayList<AccountingEntry> entries;

        // Window elements
        private HeaderBar header_bar;
        private Granite.Widgets.Toast toast;

        // Views
        private Gtk.Overlay overlay_panel;
        private MainView main_view;
        private WelcomeView welcome_view;

        // Methods
        // =======
        /// Tie to the Main Window to the Application
        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            // Set Windows defaults
            // --------------------
            this.default_height = 800;
            this.default_width = 1024;
            this.header_bar = new HeaderBar ();
            this.toast = new Granite.Widgets.Toast (_("Valoro"));
            this.assets = new HashMap<string, Asset> ();
            this.operations = new ArrayList<Operation> ();
            this.entries = new ArrayList<AccountingEntry> ();

            // Define views
            // ------------
            welcome_view = new WelcomeView ();

            // Define window events
            // --------------------
            this.header_bar.add_asset_btn.clicked.connect (on_add_asset_clicked);
            this.header_bar.add_operation_btn.clicked.connect (on_add_operation_clicked);
            this.header_bar.new_btn.clicked.connect (on_new_clicked);
            this.header_bar.open_btn.clicked.connect (on_open_clicked);
            this.header_bar.save_btn.clicked.connect (on_save_clicked);
            this.header_bar.settings_menu_btn.clicked.connect (on_menu_clicked);

            this.welcome_view.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        this.on_new_clicked ();
                        break;
                    case 1:
                        this.on_open_clicked ();
                        break;
                    case 2:
                        this.on_help_clicked ();
                        break;
                }
            });

            // Pack things
            // -----------
            this.set_titlebar(header_bar);
            this.add (welcome_view);
        }

        // Events
        // ======
        private void on_new_clicked () {
            // Remove main view and welcome view if present
            remove (overlay_panel);
            remove (welcome_view);
            file_path = null;

            // Initialize temporal storages
            assets = new HashMap<string, Asset> ();
            assets["EUR"] = new Asset ("Euro", "EUR", _("Currency"), 0.0, 0.0);

            operations = new ArrayList<Operation> ();
            entries = new ArrayList<AccountingEntry> ();

            main_view = new MainView (assets, operations, entries);
            main_view.new_book_view.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        this.on_add_asset_clicked ();
                        break;
                    case 1:
                        this.on_add_operation_clicked ();
                        break;
                }
            });

            // Create overlay
            overlay_panel = new Gtk.Overlay ();
            overlay_panel.add_overlay (main_view);
            overlay_panel.add_overlay (toast);
            add (overlay_panel);

            // Activate save, export and new operation buttons
            header_bar.subtitle = _("Unsaved logbook");
            header_bar.save_btn.set_sensitive (true);
            header_bar.add_operation_btn.set_sensitive (true);
            header_bar.add_asset_btn.set_sensitive (true);

            show_all ();
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
                    assets = new HashMap<string, Asset> ();

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
                            0.0,
                            0.0
                        );

                        assets[asset_object.get_string_member ("short_name")] = tmp_asset;
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
                                assets[source_asset], source_qty,
                                assets[destiny_asset], destiny_qty,
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
                    var message = _("%s assets and %s operations parsed.").printf (
                        assets.size.to_string (),
                        operations.size.to_string ()
                    );
                    show_toast (message);

                    // Remove main view and welcome view if present
                    remove (overlay_panel);
                    remove (welcome_view);

                    // Calculate accountancy
                    update_accounting_entries ();

                    // Call _deploy_main_layout with some data
                    main_view = new MainView (assets, operations, entries);
                    main_view.new_book_view.activated.connect ((index) => {
                        switch (index) {
                            case 0:
                                this.on_add_asset_clicked ();
                                break;
                            case 1:
                                this.on_add_operation_clicked ();
                                break;
                        }
                    });

                    // Create overlay
                    overlay_panel = new Gtk.Overlay ();
                    overlay_panel.add_overlay (main_view);
                    overlay_panel.add_overlay (toast);
                    this.add (overlay_panel);

                    this.show_all ();

                    // Activate and deactivate buttons
                    this.header_bar.save_btn.set_sensitive (false);
                    this.header_bar.add_asset_btn.set_sensitive (true);
                    this.header_bar.add_operation_btn.set_sensitive (true);
                } catch (Error e) {
                    stderr.printf ("[*] Something happened with the JSON Parser...\n");
                    toast.title = _("Could not parse the file. '%s' is corrupted. Have you edited it manually?").printf (path);
                    toast.send_notification ();
                }
            }
            dialog.close ();
        }

        private void on_save_clicked () {
            // Start a Generator and setup some fields for it
            var base_obj = new Json.Object();

            // Create array of assets
            var assets_array = new Json.Array();
            foreach(var a in assets.entries) {
                var json_asset = new Json.Object();
                json_asset.set_string_member("name", a.value.name);
                json_asset.set_string_member("short_name", a.value.short_name);
                json_asset.set_string_member("type", a.value.type);

                assets_array.add_object_element(json_asset);
            }

            // Create array of operations
            var operations_array = new Json.Array();
            foreach (Operation op in operations) {
                var json_op = new Json.Object();
                json_op.set_string_member("datetime", op.datetime.to_string ());
                json_op.set_string_member("source_asset", op.source_asset.short_name);
                json_op.set_double_member("source_qty", op.source_qty);
                json_op.set_string_member("destiny_asset", op.destiny_asset.short_name);
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

            if (this.file_path != null) {
                FileUtils.set_contents (this.file_path, gen.to_data (null));
                this.header_bar.subtitle = this.file_path;

                toast.title = _("File saved: '%s'").printf (this.file_path);
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

                    toast.title = _("File saved: '%s'").printf (this.file_path);
                    toast.send_notification ();
                }
            }

            // Deactivate save, export and new operation buttons
            this.header_bar.save_btn.set_sensitive (false);
        }

        private void on_add_asset_clicked () {
            var dialog = new AssetDialog (this);
            var tmp_asset = dialog.get_new_asset ();

            if (tmp_asset != null) {
                assets[tmp_asset.short_name] = tmp_asset;
                update_main_view (_("New asset added."));
                header_bar.save_btn.set_sensitive (true);
            } else {
                update_main_view (_("Asset discarded."));
            }

            dialog.destroy ();
        }

        private void on_add_operation_clicked () {
            var dialog = new OperationDialog (this, assets);
            var tmp_operation = dialog.get_new_operation ();

            if (tmp_operation != null) {
                operations.add (tmp_operation);
                update_main_view (_("New operation added."));

                header_bar.save_btn.set_sensitive (true);
            } else {
                update_main_view (_("Operation discarded."));
            }

            dialog.destroy ();
        }

        private void on_menu_clicked (Gtk.Button sender) {
            this.header_bar.menu.set_relative_to (sender);
            this.header_bar.menu.show_all ();
        }

        private void on_help_clicked () {
            try {
                AppInfo.launch_default_for_uri (_("https://github.com/febrezo/valoro/master/doc/support/en/"), null);
            } catch (Error e) {
                warning (e.message);
            }
        }

        private void show_toast (string message) {
            toast.title = message;
            toast.send_notification ();
        }

        private void update_main_view (string message) {
            show_toast (message);

            // Clean asset list before updating its values
            clean_asset_balance ();

            // Calculate accountancy
            update_accounting_entries ();

            // Call _deploy_main_layout with some data
            main_view.update_view (assets, operations, entries);

            main_view.new_book_view.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        this.on_add_asset_clicked ();
                        break;
                    case 1:
                        this.on_add_operation_clicked ();
                        break;
                }
            });
        }

        private void clean_asset_balance () {
            foreach (var item in assets.entries) {
                item.value.movements = new Gee.ArrayList<Movement>();
                item.value.units = 0.0;
                item.value.total_value = 0.0;
            }
        }

        private void update_accounting_entries () {
            entries = new ArrayList<AccountingEntry> ();
            foreach (Operation op in operations) {
                // Buying operations
                // -----------------
                var tmp_movement = new Movement (
                    op.destiny_qty,
                    op.normalized_qty / op.destiny_qty
                );

                assets[op.destiny_asset.short_name].movements.add (tmp_movement);
                assets[op.destiny_asset.short_name].total_value += op.normalized_qty;

                // Accounting entries only performed for cryptoassets
                // TODO: Accounting entries may be needed for any asset which is not the default one
                if (assets[op.source_asset.short_name].type == _("Cryptoasset")) {
                    var tmp_counter = op.source_qty;
                    double buying_price = 0;

                    foreach (var move in assets[op.source_asset.short_name].movements) {
                        if (tmp_counter < move.units) {
                            buying_price += tmp_counter * move.unitary_price;
                            move.units = move.units - tmp_counter;
                            break;
                        } else {
                            tmp_counter -= move.units;
                            buying_price += move.units * move.unitary_price;

                            // Set the value of the current movement to 0
                            move.units = 0;
                        }
                    }

                    // Building the accounting entry
                    var tmp_entry = new AccountingEntry (
                        op.datetime,
                        op.source_asset.short_name,
                        op.source_qty,
                        buying_price,
                        op.normalized_qty
                    );
                    entries.add (tmp_entry);
                }

                // Update units
                assets[op.destiny_asset.short_name].units += op.destiny_qty;
                assets[op.source_asset.short_name].units -= op.source_qty;
            }
        }
    }
}
