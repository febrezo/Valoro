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

namespace AppUtils {
	errordomain OperationCorrupted {
		CODE_01
	}

    public class Operation {
	    public DateTime datetime;
        public Asset source_asset;
        public double source_qty;
        public Asset destiny_asset;
        public double destiny_qty;
        public double normalized_qty; // In base currency if neither of them is EUR

	    public Operation (DateTime datetime, Asset source_asset, double source_qty, Asset destiny_asset, double destiny_qty, double normalized_qty) {
		    this.datetime = datetime;
		    this.source_asset = source_asset;
		    this.source_qty = source_qty;
		    this.destiny_asset = destiny_asset;
		    this.destiny_qty = destiny_qty;

		    if (source_asset.short_name == "EUR") {
		        this.normalized_qty = source_qty;
		    } else if (destiny_asset.short_name == "EUR") {
		        this.normalized_qty = destiny_qty;
		    } else {
		        this.normalized_qty = normalized_qty;
		    }
	    }

	    // Constructor based on strings for date
	    public Operation.from_splitted_datetime_string (string date, string time, Asset source_asset, double source_qty, Asset destiny_asset, double destiny_qty, double normalized_qty) throws OperationCorrupted.CODE_01 {
			this.datetime = new DateTime.from_iso8601 (
				date.replace ("/", "-") + " " + time,
				new TimeZone.local ()
			);
			if (this.datetime == null) {
				throw new OperationCorrupted.CODE_01 ("Date corrupted. Provided data: '%s' and '%s'.".printf (date, time));
			}

		    this.source_asset = source_asset;
		    this.source_qty = source_qty;
		    this.destiny_asset = destiny_asset;
		    this.destiny_qty = destiny_qty;

		    if (source_asset.short_name == "EUR") {
		        this.normalized_qty = source_qty;
		    } else if (destiny_asset.short_name == "EUR") {
		        this.normalized_qty = destiny_qty;
		    } else {
		        this.normalized_qty = normalized_qty;
		    }
	    }

	    // Constructor based on strings for date
	    public Operation.from_datetime_string (string datetime, Asset source_asset, double source_qty, Asset destiny_asset, double destiny_qty, double normalized_qty) throws OperationCorrupted.CODE_01 {
			this.datetime = new DateTime.from_iso8601 (
				datetime,
				new TimeZone.local ()
			);
			if (this.datetime == null) {
				throw new OperationCorrupted.CODE_01 ("Date corrupted. Provided data: '%s'.".printf (datetime));
			}

		    this.source_asset = source_asset;
		    this.source_qty = source_qty;
		    this.destiny_asset = destiny_asset;
		    this.destiny_qty = destiny_qty;

		    if (source_asset.short_name == "EUR") {
		        this.normalized_qty = source_qty;
		    } else if (destiny_asset.short_name == "EUR") {
		        this.normalized_qty = destiny_qty;
		    } else {
		        this.normalized_qty = normalized_qty;
		    }
	    }
	    
	    public string to_string () {
	        return "\nOPERATION\n---------\n\tDatetime: %s\n\tSource: %s %s\n\tDestiny: %s %s\n\tValue: %s EUR\n".printf (
	            datetime.to_string (),
				format_double_to_string (source_qty, "%.4f"),
	            source_asset.short_name.to_string (),
	            format_double_to_string (destiny_qty, "%.4f"),
	            destiny_asset.short_name.to_string (),
	            format_double_to_string (normalized_qty, "%.2f")
	        );
	    }
    }
}
