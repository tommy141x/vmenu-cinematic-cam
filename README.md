# vMenu Cinematic Camera Plugin

A cinematic camera plugin for vMenu, provides the menu "cinematic_cam" which can be opened with the cinecam command.

This resource serves as an example of how to create a plugin using vMenu's export system, and provides a complete reference for vMenu's export functions, allowing other resources to create addon plugins that integrate with vMenu's menu system.

## Initialization

### OnReady

Registers a callback to be invoked when vMenu is fully initialized and ready. This is the recommended way to initialize your plugin.

**Syntax:**
```lua
exports['vMenu']:OnReady(callback)
```

**Parameters:**
- `callback` (function, required): Function to call when vMenu is ready

**Important:** If your callback performs asynchronous work (menu modifications, waits, etc.), wrap your logic in `Citizen.CreateThread()` to prevent serialization errors.

**Example:**
```lua
-- Simple callback (no async work)
exports.vMenu:OnReady(function()
    print('vMenu is ready!')
end)

-- Callback with async work (menu modifications, waits, etc.)
exports.vMenu:OnReady(function()
    Citizen.CreateThread(function()
        setupMyMenus()
    end)
end)
```

**How it works:**
- If vMenu is already ready when you call `OnReady`, your callback fires immediately
- If vMenu is not ready yet, your callback is queued and fires when vMenu finishes initialization
- This eliminates the need for complex event handlers and timing checks

---

### IsReady

Checks if vMenu is ready for external interactions.

**Syntax:**
```lua
local ready = exports['vMenu']:IsReady()
```

**Returns:**
- `boolean`: True if vMenu is ready, false otherwise

**Example:**
```lua
if exports.vMenu:IsReady() then
    print('vMenu is ready!')
else
    print('vMenu is still initializing...')
end
```

---

## Menu Management

### CreateMenu

Creates a new dynamic menu.

**Syntax:**
```lua
exports['vMenu']:CreateMenu(menuId, menuTitle, menuDescription, callback)
```

**Parameters:**
- `menuId` (string, required): Unique identifier for the menu
- `menuTitle` (string, optional): Display title (default: "Menu")
- `menuDescription` (string, optional): Subtitle text (default: "")
- `callback` (function, optional): Function called when menu opens

**Example:**
```lua
exports['vMenu']:CreateMenu('my-custom-menu', 'Custom Menu', 'My Plugin Menu', function()
    print('Menu opened!')
end)
```

---

### OpenMenu

Opens a menu by ID (works with both custom and built-in vMenu menus).

**Syntax:**
```lua
exports['vMenu']:OpenMenu(menuId)
```

**Parameters:**
- `menuId` (string, required): Menu identifier

**Example:**
```lua
exports['vMenu']:OpenMenu('my-custom-menu')
exports['vMenu']:OpenMenu('player-options') -- Opens built-in menu
```

---

### CloseMenu

Closes a specific menu.

**Syntax:**
```lua
exports['vMenu']:CloseMenu(menuId)
```

**Parameters:**
- `menuId` (string, required): Menu identifier

**Example:**
```lua
exports['vMenu']:CloseMenu('my-custom-menu')
```

---

### CloseAllMenus

Closes all open menus.

**Syntax:**
```lua
exports['vMenu']:CloseAllMenus()
```

**Example:**
```lua
exports['vMenu']:CloseAllMenus()
```

---

### CheckMenu

Checks if a menu exists.

**Syntax:**
```lua
local exists = exports['vMenu']:CheckMenu(menuId)
```

**Parameters:**
- `menuId` (string, required): Menu identifier

**Returns:**
- `boolean`: True if menu exists, false otherwise

**Example:**
```lua
if exports['vMenu']:CheckMenu('my-custom-menu') then
    print('Menu exists!')
end
```

---

### ClearMenu

Removes all items from a menu.

**Syntax:**
```lua
exports['vMenu']:ClearMenu(menuId)
```

**Parameters:**
- `menuId` (string, required): Menu identifier

**Example:**
```lua
exports['vMenu']:ClearMenu('my-custom-menu')
```

---

### RefreshMenu

Refreshes a menu's display (useful after adding/removing items).

**Syntax:**
```lua
exports['vMenu']:RefreshMenu(menuId)
```

**Parameters:**
- `menuId` (string, required): Menu identifier

**Example:**
```lua
exports['vMenu']:RefreshMenu('my-custom-menu')
```

---

### DeleteMenu

Permanently deletes a dynamic menu (only works with menus created via CreateMenu).

**Syntax:**
```lua
exports['vMenu']:DeleteMenu(menuId)
```

**Parameters:**
- `menuId` (string, required): Menu identifier

**Example:**
```lua
exports['vMenu']:DeleteMenu('my-custom-menu')
```

---

### GetAllMenuIds

Returns all available menu IDs (both custom and built-in).

**Syntax:**
```lua
local menuIds = exports['vMenu']:GetAllMenuIds()
```

**Returns:**
- `string[]`: Array of all menu IDs (regardless of permissions)

**Example:**
```lua
local menus = exports['vMenu']:GetAllMenuIds()
for _, menuId in ipairs(menus) do
    print('Available menu: ' .. menuId)
end
```

---

### IsMenuPermitted

Checks if a menu is permitted based on vMenu permissions.

**Syntax:**
```lua
local permitted = exports['vMenu']:IsMenuPermitted(menuId)
```

**Parameters:**
- `menuId` (string, required): Menu identifier

**Returns:**
- `boolean`: True if the player has permission to access the menu, false otherwise

**Example:**
```lua
local menuIds = exports.vMenu:GetAllMenuIds()
for _, menuId in ipairs(menuIds) do
    if exports.vMenu:IsMenuPermitted(menuId) then
        print('Player can access: ' .. menuId)
    else
        print('Player cannot access: ' .. menuId)
    end
end
```

**Note:** Use this to filter menus before displaying them to players, especially when reorganizing the main menu.

---

## Menu Items

### AddButton

Adds a clickable button to a menu.

**Syntax:**
```lua
exports['vMenu']:AddButton(menuId, buttonId, buttonLabel, buttonDescription, rightLabel, callback)
```

**Parameters:**
- `menuId` (string, required): Target menu ID
- `buttonId` (string, required): Unique button identifier
- `buttonLabel` (string, optional): Button text (default: "Button")
- `buttonDescription` (string, optional): Description text (default: "")
- `rightLabel` (string, optional): Text displayed on right side of button
- `callback` (function, optional): Function called when button is pressed

**Example:**
```lua
exports['vMenu']:AddButton('my-custom-menu', 'test-button', 'Click Me', 'This is a test button', '→', function()
    print('Button clicked!')
end)
```

**Legacy Syntax (still supported):**
```lua
exports['vMenu']:AddButton(menuId, buttonId, buttonLabel, buttonDescription, callback)
```

---

### AddList

Adds a scrollable list item to a menu.

**Syntax:**
```lua
exports['vMenu']:AddList(menuId, listId, listLabel, options, defaultIndex, description, callback)
```

**Parameters:**
- `menuId` (string, required): Target menu ID
- `listId` (string, required): Unique list identifier
- `listLabel` (string, optional): List text (default: "List")
- `options` (table/array, required): List options array
- `defaultIndex` (number, optional): Starting index (0-based, default: 0)
- `description` (string, optional): Description text (default: "")
- `callback` (function, optional): Function called on list change

**Callback Parameters:**
- `selected` (boolean): True if item was selected (Enter pressed), false if just browsing
- `currentValue` (string): Current selected option text
- `currentIndex` (number): Current index
- `oldIndex` (number): Previous index

**Example:**
```lua
local options = {'Option 1', 'Option 2', 'Option 3'}
exports['vMenu']:AddList('my-custom-menu', 'test-list', 'Choose Option', options, 0, 'Select an option', function(selected, value, index, oldIndex)
    if selected then
        print('Selected: ' .. value .. ' at index ' .. index)
    else
        print('Browsing: ' .. value)
    end
end)
```

---

### AddCheckbox

Adds a checkbox item to a menu.

**Syntax:**
```lua
exports['vMenu']:AddCheckbox(menuId, checkboxId, checkboxLabel, description, defaultValue, callback)
```

**Parameters:**
- `menuId` (string, required): Target menu ID
- `checkboxId` (string, required): Unique checkbox identifier
- `checkboxLabel` (string, optional): Checkbox text (default: "Checkbox")
- `description` (string, optional): Description text (default: "")
- `defaultValue` (boolean, optional): Initial checked state (default: false)
- `callback` (function, optional): Function called when checkbox is toggled

**Callback Parameters:**
- `checked` (boolean): New checkbox state

**Example:**
```lua
exports['vMenu']:AddCheckbox('my-custom-menu', 'test-checkbox', 'Enable Feature', 'Toggle this feature', false, function(checked)
    print('Checkbox is now: ' .. tostring(checked))
end)
```

---

### AddSlider

Adds a slider item to a menu (0-10 range, representing 0-100%).

**Syntax:**
```lua
exports['vMenu']:AddSlider(menuId, sliderId, sliderLabel, description, defaultValue, callback)
```

**Parameters:**
- `menuId` (string, required): Target menu ID
- `sliderId` (string, required): Unique slider identifier
- `sliderLabel` (string, optional): Slider text (default: "Slider")
- `description` (string, optional): Description text (default: "")
- `defaultValue` (number, optional): Initial value 0-10 (default: 0)
- `callback` (function, optional): Function called when slider moves

**Callback Parameters:**
- `oldPosition` (number): Previous slider position (0-10)
- `newPosition` (number): New slider position (0-10)

**Example:**
```lua
exports['vMenu']:AddSlider('my-custom-menu', 'volume-slider', 'Volume', 'Adjust volume level', 5, function(oldPos, newPos)
    local percentage = (newPos / 10) * 100
    print('Volume: ' .. percentage .. '%')
end)
```

---

### AddSpacer

Adds a spacer/separator to a menu.

**Syntax:**
```lua
exports['vMenu']:AddSpacer(menuId, spacerId, spacerText, description)
```

**Parameters:**
- `menuId` (string, required): Target menu ID
- `spacerId` (string, required): Unique spacer identifier
- `spacerText` (string, optional): Spacer text (default: "---")
- `description` (string, optional): Description text (default: "")

**Example:**
```lua
exports['vMenu']:AddSpacer('my-custom-menu', 'section-1', '~b~Section 1', '')
```

---

### AddSubmenuButton

Adds a button that links to another menu (creates submenu navigation).

**Syntax:**
```lua
exports['vMenu']:AddSubmenuButton(parentMenuId, buttonId, submenuId, buttonLabel, buttonDescription, callback)
```

**Parameters:**
- `parentMenuId` (string, required): Parent menu ID
- `buttonId` (string, required): Unique button identifier
- `submenuId` (string, required): Target submenu ID (must exist)
- `buttonLabel` (string, optional): Button text (default: "Submenu")
- `buttonDescription` (string, optional): Description text (default: "")
- `callback` (function, optional): Function called when button is pressed

**Example:**
```lua
-- Create parent and submenu first
exports['vMenu']:CreateMenu('parent-menu', 'Parent Menu', 'Main Menu')
exports['vMenu']:CreateMenu('child-menu', 'Child Menu', 'Submenu')

-- Link them together
exports['vMenu']:AddSubmenuButton('parent-menu', 'child-button', 'child-menu', 'Open Submenu', 'Opens the child menu')
```

---

### RemoveItem

Removes an item from a menu by ID or index.

**Syntax:**
```lua
exports['vMenu']:RemoveItem(menuId, itemIdOrIndex)
```

**Parameters:**
- `menuId` (string, required): Target menu ID
- `itemIdOrIndex` (string|number, required): Item ID or index (0-based)

**Example:**
```lua
-- Remove by ID
exports['vMenu']:RemoveItem('my-custom-menu', 'test-button')

-- Remove by index
exports['vMenu']:RemoveItem('my-custom-menu', 0)
```

---

## Utilities

### Notify

Displays a notification to the player.

**Syntax:**
```lua
exports['vMenu']:Notify(message, type)
```

**Parameters:**
- `message` (string, required): Notification text
- `type` (string, optional): Notification type: "error", "info", "success", or default

**Example:**
```lua
exports['vMenu']:Notify('Hello World!', 'info')
exports['vMenu']:Notify('Something went wrong!', 'error')
exports['vMenu']:Notify('Task completed!', 'success')
exports['vMenu']:Notify('Default notification')
```

---

## Examples

### Basic Plugin Setup

The simplest way to initialize your vMenu plugin using the new `OnReady` system:

```lua
exports.vMenu:OnReady(function()
    Citizen.CreateThread(function()
        -- Create your menu
        exports.vMenu:CreateMenu('my-plugin', 'My Plugin', 'Example Plugin')

        -- Add menu items
        exports.vMenu:AddButton('my-plugin', 'test-btn', 'Test Button', 'Click me!', nil, function()
            print('Button clicked!')
        end)

        -- Register command to open menu
        RegisterCommand('myplugin', function()
            exports.vMenu:OpenMenu('my-plugin')
        end)
    end)
end)
```

**Why wrap in `Citizen.CreateThread`?**
When your callback performs asynchronous work like menu modifications, wrapping in a thread prevents Lua return value serialization errors.

---

### Complete Plugin Example (Lua)

```lua
local function setupPlugin()
    -- Create main menu
    exports.vMenu:CreateMenu('my-plugin', 'My Plugin', 'Example Plugin Menu', function()
        print('My Plugin menu opened!')
    end)

    -- Add a button
    exports.vMenu:AddButton('my-plugin', 'spawn-vehicle', 'Spawn Vehicle', 'Spawns a vehicle', nil, function()
        local vehicleHash = GetHashKey('adder')
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        RequestModel(vehicleHash)
        while not HasModelLoaded(vehicleHash) do
            Wait(0)
        end

        local vehicle = CreateVehicle(vehicleHash, coords.x, coords.y, coords.z, GetEntityHeading(playerPed), true, false)
        SetPedIntoVehicle(playerPed, vehicle, -1)

        exports.vMenu:Notify('Vehicle spawned!', 'success')
    end)

    -- Add a checkbox
    local godModeEnabled = false
    exports.vMenu:AddCheckbox('my-plugin', 'godmode-toggle', 'God Mode', 'Toggle invincibility', false, function(checked)
        godModeEnabled = checked
        SetEntityInvincible(PlayerPedId(), checked)
        exports.vMenu:Notify('God Mode: ' .. tostring(checked), 'info')
    end)

    -- Add a list
    local weaponList = {'WEAPON_PISTOL', 'WEAPON_SMG', 'WEAPON_RIFLE'}
    local weaponNames = {'Pistol', 'SMG', 'Rifle'}
    exports.vMenu:AddList('my-plugin', 'weapon-list', 'Give Weapon', weaponNames, 0, 'Select a weapon', function(selected, value, index)
        if selected then
            GiveWeaponToPed(PlayerPedId(), GetHashKey(weaponList[index + 1]), 250, false, true)
            exports.vMenu:Notify('Given: ' .. value, 'success')
        end
    end)

    -- Add submenu
    exports.vMenu:CreateMenu('my-plugin-settings', 'Settings', 'Plugin Settings')
    exports.vMenu:AddSubmenuButton('my-plugin', 'settings-btn', 'my-plugin-settings', 'Settings', 'Configure plugin')

    -- Add items to submenu
    exports.vMenu:AddCheckbox('my-plugin-settings', 'auto-heal', 'Auto Heal', 'Automatically heal player', false, function(checked)
        print('Auto heal: ' .. tostring(checked))
    end)

    -- Command to open menu
    RegisterCommand('myplugin', function()
        exports.vMenu:OpenMenu('my-plugin')
    end)
end

-- Initialize using OnReady
exports.vMenu:OnReady(function()
    Citizen.CreateThread(setupPlugin)
end)
```

---

### Adding to Built-in vMenu Menus

```lua
exports.vMenu:OnReady(function()
    Citizen.CreateThread(function()
        -- Add a button to the Vehicle Options menu
        if exports.vMenu:CheckMenu('vehicle-options') then
            exports.vMenu:AddButton('vehicle-options', 'custom-paint', 'Custom Paint Job', 'Apply custom paint', nil, function()
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if vehicle ~= 0 then
                    SetVehicleCustomPrimaryColour(vehicle, 255, 0, 0)
                    SetVehicleCustomSecondaryColour(vehicle, 0, 0, 255)
                    exports.vMenu:Notify('Custom paint applied!', 'success')
                end
            end)
        end
    end)
end)
```

---

### Dynamic Menu Creation

```lua
-- Create a menu dynamically based on server data
RegisterNetEvent('myresource:showVehicleMenu', function(vehicles)
    -- Create menu if it doesn't exist
    if not exports.vMenu:CheckMenu('vehicle-catalog') then
        exports.vMenu:CreateMenu('vehicle-catalog', 'Vehicle Catalog', 'Available Vehicles')
    else
        exports.vMenu:ClearMenu('vehicle-catalog')
    end

    -- Add vehicles dynamically
    for i, vehicle in ipairs(vehicles) do
        exports.vMenu:AddButton('vehicle-catalog', 'vehicle-' .. i, vehicle.name, vehicle.description, '$' .. vehicle.price, function()
            TriggerServerEvent('myresource:purchaseVehicle', vehicle.id)
        end)
    end

    -- Open the menu
    exports.vMenu:OpenMenu('vehicle-catalog')
end)
```

---

### Menu Reorganization

Example of reorganizing the vMenu main menu with permission checking:

```lua
exports.vMenu:OnReady(function()
    Citizen.CreateThread(function()
        -- Get all available menus
        local allMenus = exports.vMenu:GetAllMenuIds()

        -- Clear main menu (keeping first item - Online Players)
        for i = 1, 20 do
            local success = pcall(function()
                exports.vMenu:RemoveItem('main-menu', 1)
            end)
            if not success then break end
        end

        -- Define desired menu order
        local desiredOrder = {
            {id = 'player-related-options', name = 'Player Options', desc = 'Player related options'},
            {id = 'vehicle-related-options', name = 'Vehicle Options', desc = 'Vehicle related options'},
            {id = 'world-options', name = 'World Options', desc = 'World related options'},
            {id = 'misc-settings', name = 'Misc Settings', desc = 'Miscellaneous settings'},
        }

        -- Add menus in desired order (with permission check)
        for _, menuItem in ipairs(desiredOrder) do
            -- Check if menu exists
            local exists = false
            for _, availableId in ipairs(allMenus) do
                if availableId == menuItem.id then
                    exists = true
                    break
                end
            end

            -- Check if player has permission
            if exists and exports.vMenu:IsMenuPermitted(menuItem.id) then
                exports.vMenu:AddSubmenuButton('main-menu', menuItem.id .. '_btn', menuItem.id, menuItem.name, menuItem.desc)
                print('Added menu: ' .. menuItem.name)
            else
                print('Skipping menu: ' .. menuItem.name .. ' (not permitted or unavailable)')
            end
        end
    end)
end)
```

---

## Built-in Menu IDs

Common built-in vMenu menus you can extend:

- `player-options` - Player Options menu
- `player-related-options` - Player Related Options (parent menu)
- `online-players` - Online Players menu
- `vehicle-options` - Vehicle Options menu
- `vehicle-related-options` - Vehicle Related Options (parent menu)
- `vehicle-spawner` - Vehicle Spawner menu
- `player-appearance` - Player Appearance menu
- `weapon-options` - Weapon Options menu
- `world-options` - World Options menu (time/weather)
- `voice-chat-settings` - Voice Chat Settings menu
- `misc-settings` - Miscellaneous Settings menu
- `recording-options` - Recording Options menu
- `about-vmenu` - About vMenu menu

**Note:** Use `GetAllMenuIds()` to get a complete list of available menus at runtime, and use `IsMenuPermitted()` to check if the player has access to a specific menu.
