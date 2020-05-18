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
using AppWidgets;

namespace AppWidgets {
    public class HeaderBar : Gtk.HeaderBar {
        public Gtk.Button new_btn;
        public Gtk.Button open_btn;
        public Gtk.Button save_btn;
        public Gtk.Button add_operation_btn;
        public Gtk.Button add_asset_btn;
        public Gtk.Button settings_menu_btn;
        public SettingsMenu menu;

        public HeaderBar () {
            this.show_close_button = true;
            this.title = _("Valoro");

            // Set Menu 
            // --------
            this.menu = new SettingsMenu ();

            // Gtk Settings
            var granite_settings = Granite.Settings.get_default ();
            var gtk_settings = Gtk.Settings.get_default ();

            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            granite_settings.notify["prefers-color-scheme"].connect (() => {
                gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            });

            // Add menu buttons 
            // ----------------

            // New button
            new_btn = new Gtk.Button.from_icon_name ("document-new", Gtk.IconSize.LARGE_TOOLBAR);
            new_btn.tooltip_text = _("Create new logbook");
            this.pack_start (new_btn);

            // Open button
            open_btn = new Gtk.Button.from_icon_name ("document-open", Gtk.IconSize.LARGE_TOOLBAR);
            open_btn.tooltip_text = _("Open logbook");

            this.pack_start (open_btn);

            // Save button
            save_btn = new Gtk.Button.from_icon_name ("document-save-as", Gtk.IconSize.LARGE_TOOLBAR);
            save_btn.tooltip_text = _("Save logbook as…");
            save_btn.set_sensitive (false);
            this.pack_start (save_btn);

            // Menu button
            settings_menu_btn = new Gtk.Button.from_icon_name ("open-menu-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            settings_menu_btn.tooltip_text = _("Open menu");

            this.pack_end (settings_menu_btn);

            // Add operation button
            add_operation_btn = new Gtk.Button.from_icon_name ("event-new", Gtk.IconSize.LARGE_TOOLBAR);
            settings_menu_btn.tooltip_text = _("Add new operation");
            add_operation_btn.set_sensitive (false);
            this.pack_end (add_operation_btn);

            // Add asset button
            add_asset_btn = new Gtk.Button.from_icon_name ("application-vnd.openxmlformats-officedocument.presentationml.presentation", Gtk.IconSize.LARGE_TOOLBAR);
            settings_menu_btn.tooltip_text = _("Add new asset");
            add_asset_btn.set_sensitive (false);
            this.pack_end (add_asset_btn);        
        }
    }
}
