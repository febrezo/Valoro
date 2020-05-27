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
	errordomain AccountingEntryCorrupted {
		CODE_01
	}

    public class AccountingEntry {
	    public DateTime datetime;
        public string asset_id;
        public double asset_units;
        public double buying_price;
        public double selling_price;
        public double benefit;

	    public AccountingEntry (DateTime datetime, string asset_id, double asset_units, double buying_price, double selling_price) {
		    this.datetime = datetime;
		    this.asset_id = asset_id;
		    this.asset_units = asset_units;
            this.buying_price = buying_price;
            this.selling_price = selling_price;
            this.benefit = selling_price - buying_price;
	    }

	    // Constructor based on strings for date
	    public AccountingEntry.from_splitted_datetime_string (string date, string time, string asset_id, double asset_units, double buying_price, double selling_price) throws AccountingEntryCorrupted.CODE_01 {
			this.datetime = new DateTime.from_iso8601 (
				date.replace ("/", "-") + " " + time,
				new TimeZone.local ()
			);
			if (this.datetime == null) {
				throw new AccountingEntryCorrupted.CODE_01 ("Date corrupted. Provided data: '%s' and '%s'.".printf (date, time));
			}

		    this.datetime = datetime;
		    this.asset_id = asset_id;
		    this.asset_units = asset_units;
            this.buying_price = buying_price;
            this.selling_price = selling_price;
            this.benefit = selling_price - buying_price;
	    }

	    // Constructor based on strings for date
	    public AccountingEntry.from_datetime_string (string datetime, string asset_id, double asset_units, double buying_price, double selling_price)  throws AccountingEntryCorrupted.CODE_01 {
			this.datetime = new DateTime.from_iso8601 (
				datetime,
				new TimeZone.local ()
			);
			if (this.datetime == null) {
				throw new AccountingEntryCorrupted.CODE_01 ("Date corrupted. Provided data: '%s'.".printf (datetime));
			}

		    this.asset_id = asset_id;
		    this.asset_units = asset_units;
            this.buying_price = buying_price;
            this.selling_price = selling_price;
            this.benefit = selling_price - buying_price;
	    }
	    
	    
	    public string to_string () {
	        return "\nENTRY\n-----\n\tDatetime: %s\n\tSource: %s %s\n\tBuying price: %s\n\tSelling price: %s\n\tBenefit: %s\n".printf (
	            datetime.to_string (),
	            format_double_to_string (asset_units, "%.4f"),
	            asset_id,
	            format_double_to_string (buying_price, "%.2f"),
	            format_double_to_string (selling_price, "%.2f"),
	            format_double_to_string (benefit, "%.2f")
	        );
	    }
    }
}
