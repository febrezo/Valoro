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

namespace Valoro {
    public class Window : Gtk.ApplicationWindow {
    
        /// Tie to the Main Window to the Application    
        public Window (Gtk.Application app) {
            Object (application: app);
        }
        
        construct {
            this.default_height = 400;
            this.default_width = 600;
            
            // Define views
            // ------------
            var welcome = new WelcomeView ();
            
            // Define the header
            // -----------------
            var header_bar = new Gtk.HeaderBar();
            header_bar.show_close_button = true;
            header_bar.title = _("Valoro");
            
            // New button
            var new_btn = new Gtk.Button.from_icon_name ("document-new");
            new_btn.clicked.connect (on_open_clicked);
            header_bar.pack_start (new_btn);

            // Open button
            var open_btn = new Gtk.Button.from_icon_name ("document-open");
            header_bar.pack_start (open_btn);
            
            // Save button
            var save_btn = new Gtk.Button.from_icon_name ("document-save");
            header_bar.pack_start (save_btn);

            // Export PDF button
            var export_pdf_btn = new Gtk.Button.from_icon_name ("application-pdf");
            header_bar.pack_start (export_pdf_btn);

            // Menubutton
            var menu_btn = new Gtk.Button.from_icon_name ("open-menu-symbolic");
            header_bar.pack_end (menu_btn);

            // Add operation button
            var add_operation_btn = new Gtk.Button.from_icon_name ("event-new");
            header_bar.pack_end (add_operation_btn);
            
            // Pack things 
            // -----------
            this.set_titlebar(header_bar);
            this.add (welcome);
        }

        private void on_open_clicked () {
            var dialog = new Gtk.FileChooserDialog (
                _("Open assets file"), // Title
                this, // Parent Window
                Gtk.FileChooserAction.OPEN, // Action: OPEN, SAVE, CREATE_FOLDER, SELECT_FOLDER
                _("Cancel"),
                Gtk.ResponseType.CANCEL,
                _("Open"),
                Gtk.ResponseType.ACCEPT
            );
            
            var res = dialog.run ();
            
            if (res == Gtk.ResponseType.ACCEPT) {
                print ("[*] Selected file: '%s'".printf (dialog.get_filename ()));
            };
            
            dialog.close ();
        }
    }
}
