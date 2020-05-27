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

namespace AppWidgets {
    public class AssetPanel : Granite.Widgets.SourceList {
        // Cosntructors
        // ============
        public AssetPanel (HashMap<string, Asset> assets) {
            var currency_category = new Granite.Widgets.SourceList.ExpandableItem (_("Currencies"));
            currency_category.expand_all ();

            var cryptoasset_category = new Granite.Widgets.SourceList.ExpandableItem (_("Cryptoassets"));
            cryptoasset_category.expand_all ();

            foreach (var asset in assets.entries) {
                var new_item = new Granite.Widgets.SourceList.ExpandableItem ("%s".printf (asset.value.name));
                string format = "%.2f";
                if (asset.value.type == _("Cryptoasset")) {
                    format = "%.4f";
                }
                new_item.badge = AppUtils.format_double_to_string (asset.value.units, format) + " " + asset.value.short_name;

                var avg_price_item = new Granite.Widgets.SourceList.Item (_("Average acquisition price: "));
                avg_price_item.badge = AppUtils.format_double_to_string(asset.value.total_value / asset.value.units, "%.2f");
                if (avg_price_item.badge == "-nan" || avg_price_item.badge == "inf") {
                    avg_price_item.badge = _("N/A");
                } else {
                    avg_price_item.badge += " " + "EUR";
                }

                var total_price_item = new Granite.Widgets.SourceList.Item (_("Total acquisition value: "));
                total_price_item.badge = AppUtils.format_double_to_string(asset.value.total_value, "%.2f") + " " + "EUR";

                new_item.add (avg_price_item);
                new_item.add (total_price_item);

                if (asset.value.type == _("Currency")) {
                    currency_category.add (new_item);
                } else {
                    cryptoasset_category.add (new_item);
                }
            }

            // Add root folder
            this.root.add (currency_category);
            this.root.add (cryptoasset_category);
        }
    }
}
