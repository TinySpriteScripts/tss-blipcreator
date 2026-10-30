# [`tss-blipcreator`] by [TinySprite Scripts (TSS)](https://yourstorelink.com) | [Discord](https://discord.gg/ZMFfC54FdJ) | [Support Us](https://ko-fi.com/tinyspritescripts)

Create your own personalised blips on runtime, mark locations to revisit, mark your own homes, fully customisable and saves through restarts

---

## 🔧 Support
Need help with setup or encountering issues? Join our Discord: [Join Support Server](https://discord.gg/ZMFfC54FdJ)

---

## ❤️ Credits
- TinySprite Scripts for tss_bridge

---

## 🧰 Installation

1. Create a folder called `[tinysprite]` in your server resources directory (if not already existing)
2. Place the `tss-blipcreator` resource in that subfolder
3. Ensure it is started in your `server.cfg`:
   ```cfg
   # Start your framework and inventory first
   ensure oxmysql
   ensure tss_bridge
   ensure tss-blipcreator
   ```
4. Run the file `player_blips.sql` in your database
5. Configure script to your liking

---

## 📦 Dependencies
- `tss_bridge`
- `oxmysql`
- A framework supported by tss_bridge (QB-Core, Qbox or ESX)

---

## ✨ Features
- Pre-Approved Options
   - Pre configure the options available to users
 - Item or Command / radial Setup
   - Use blipcreator as an item
   - use as command
   - use in radial menu
 - Default Blips
   - Setup Default blips to show to everybody
   - Personal blips created in game and persistent
 - Custom Blips
   - Setup custom blips (visible only by the player)
   - Customise the size, colour, label, sprite of your blips
   - Share your blips with nearby friends
   - Fast Travel to your blips (configurable)
   - Ping your blips to find them easier in game


---

## 📬 Contact

- Tebex: [https://yourstorelink.com](https://yourstorelink.com)
- Discord: [TinySprite Scripts](https://discord.gg/ZMFfC54FdJ)
- Ko-fi: [https://ko-fi.com/tinyspritescripts](https://ko-fi.com/tinyspritescripts)

---

## 🧾 Changelog

### v1.2
- Initial tss release
- Key features listed
- tss_bridge integration

---

**© TinySprite Scripts** — Quality resources built for FiveM servers.
## Bridge setup

Menus and marker forms use the built-in TSS UI. Choose the label, sprite,
colour and scale from the marker menu, then select Create or Update.
Notifications and inventory selection follow tss_bridge configuration; the old
per-script Menu, Notify, ProgressBar and Crafting settings are no longer used.
Existing player_blips records and event names are preserved.
The GPS item must already exist in your inventory. Its use handler is registered
through `TSS.Inventory.CreateUseableItem`; the bridge selects the provider.
For OX, use a plain item definition without `consume`, client use actions or a
server export so OX routes use through the ESX/Qbox framework callback.

Open the menu from a client command or radial action with:
```lua
TriggerEvent('tss-blipcreator:client:OpenMenu')
```

After updating, restart tss-blipcreator with tss_bridge already running.
Test creating, editing, deleting and sharing a marker, and reconnect to verify
saved markers load. Test the configured GPS item and required-item setting too.

## Blip lifecycle

Default markers, personal markers, temporary pings and GPS routes are created
through `TSS.Blips`. Edits and visibility changes use `TSS.Blips.Update` without
replacing handles. The bridge cleans up this resource's blips when it stops;
character switches call `TSS.Blips.Clear`. Deleting a personal marker also removes
its active ping and GPS route.
