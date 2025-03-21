# WeaponsSync

A highly configurable ESX-based solution for synchronizing a player’s weapons and corresponding ammo with their inventory. It ensures that any weapon you possess is tied to an actual inventory item and accurately reflects ammo usage at all times.

---

## Overview

WeaponsSync offers the following key features:

- **Automatic Loadout Handling**  
  Whenever your inventory changes, the script updates your in-game weapons and ammo to match your actual items.

- **Ammo Consumption**  
  Each shot fired deducts the corresponding ammo items from your inventory in real time.

- **Ammo Box Conversions**  
  Special “box” items can be opened to provide multiple units of the related ammo type.

- **Easy Extensibility**  
  By adjusting a simple configuration, you can effortlessly add new weapons, ammo types, or modify existing ones.

---

## Installation & Usage

1. **Place the Resource**  
   Copy this resource’s files into any folder within your server’s `resources/` directory (commonly named `WeaponsSync`).

2. **Run the SQL**  
   Execute the provided SQL (e.g., `items.sql`) in your database to create or update the necessary weapon and ammo items.

3. **Replace `esx:removeInventoryItem` Logic**  
   In `es_extended/client/main.lua`, **remove or comment out** the original `RegisterNetEvent('esx:removeInventoryItem', ...)` block and **insert** the following:

   ```lua
   RegisterNetEvent('esx:removeInventoryItem', function(itemName, count, silent)
       local inventoryDict = {}
       for _, invItem in ipairs(ESX.PlayerData.inventory) do
           inventoryDict[invItem.name] = invItem
       end

       if inventoryDict[itemName] then
           inventoryDict[itemName] = {
               name = itemName,
               count = inventoryDict[itemName].count - count,
               label = inventoryDict[itemName].label
           }
       end

       local updatedInventory = {}
       for _, v in pairs(inventoryDict) do
           updatedInventory[#updatedInventory + 1] = v
       end
       ESX.PlayerData.inventory = updatedInventory

       if not silent then
           ESX.UI.ShowInventoryItemNotification(false, {name = itemName, count = count}, count)
       end

       if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
           ESX.ShowInventory()
       end
   end)
   ```

   This ensures proper inventory synchronization whenever items are removed (e.g., using ammo).

---

## Adding or Changing Weapons & Ammo

- **Add a New Weapon**  
  1. Insert a corresponding record in your `items` table (e.g., `my_new_weapon`).  
  2. Add a new entry in the configuration (for example, `config.lua`) mapping the GTA weapon name to this item.

- **Add a New Ammo Type**  
  1. Insert a new ammo item in the `items` table (e.g., `my_ammo_type`).  
  2. In the configuration, define an entry that points to the new item for the relevant ammo type.

---

## Functionality

WeaponsSync continuously ensures that your loadout reflects what you actually own in your ESX inventory. It tracks when you fire weapons, removes the appropriate ammo items, and even handles handy conversions from ammo boxes to individual ammo units.

---

## Credits

Developed to streamline weapon and ammo inventory synchronization in ESX. Feel free to adapt or extend it as needed.

**Enjoy and happy gaming!**