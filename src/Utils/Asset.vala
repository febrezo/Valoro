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

namespace AppUtils {
    public class Asset {
        public string name;
        public string short_name;
        public string type;
        public double units;
        public double total_value;
        public ArrayList<Movement> movements;

	    public Asset (string name, string short_name, string type, double units, double total_value) {
		    this.name = name;
		    this.short_name = short_name.up ();
		    this.type = type;
		    this.units = units;
		    this.total_value = total_value;
		    this.movements = new ArrayList<Movement> ();
	    }

	    public string to_string () {
	        return "\nASSET\n-----\n\tName: %s (%s)\n\tType: %s\n\tUnits: %s\n\tAverage price: %s\n\tTotal movements: %s\n".printf (
	            name,
	            short_name,
	            type,
	            format_double_to_string (units, "%.4f"),
	            format_double_to_string (total_value / units, "%.2f"),
	            movements.size.to_string ()
	        );
	    }
    }
}
