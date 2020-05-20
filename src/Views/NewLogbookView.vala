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

namespace AppViews {
    public class NewLogbookView : Granite.Widgets.Welcome {
        public NewLogbookView () {
            Object ();
        } 
        
        construct {
            //this.title = _("New logbook");
            this.subtitle = _("Start adding assets and operations to track your own movements");
            this.append ("application-vnd.openxmlformats-officedocument.presentationml.presentation", _("Add new asset"), _("Introduce the details of a new asset you want to register."));
            this.append ("event-new", _("Add new operation"), _("Introduce the details of the operation you want to register."));
        }
    }
}
