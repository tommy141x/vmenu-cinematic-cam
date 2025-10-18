# vMenu Cinematic Camera Plugin

A cinematic camera plugin for vMenu, provides the menu "cinematic_cam" which can be opened with the cinecam command.

This resource serves as an example of how to create a plugin using vMenu's export system, and provides a complete reference for vMenu's export functions, allowing other resources to create addon plugins that integrate with vMenu's menu system.

## Menu Initialization Timing

When creating menus with `CreateMenu`, the player name displayed in the menu header is cached at creation time. If the menu is created immediately on script load, it may show "Player 2" instead of the actual player name. To avoid this, delay menu creation until vMenu is fully initialized:

```lua
local resourceName = GetCurrentResourceName()

AddEventHandler("vMenu:SetupTickFunctions", function()
    Citizen.Wait(100)
    createYourMenu()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == resourceName then
        if exports.vMenu and exports.vMenu:CheckMenu("main-menu") then
            Citizen.Wait(1000)
            createYourMenu()
        end
    end
end)
```

## Table of Contents

1. [Menu Management](#menu-management)
2. [Menu Items](#menu-items)
3. [Utilities](#utilities)
4. [Examples](#examples)

---

## Menu Management

### CreateMenu

Creates a new dynamic menu.

**Syntax:**
```lua
exports['vmenu']:CreateMenu(menuId, menuTitle, menuDescription, callback)
```

**Parameters:**
- `menuId` (string, required): Unique identifier for the menu
- `menuTitle` (string, optional): Display title (default: "Menu")
- `menuDescription` (string, optional): Subtitle text (default: "")
- `callback` (function, optional): Function called when menu opens

Note: The player name shown in the menu header is cached when this function is called. See [Menu Initialization Timing](#menu-initialization-timing) for proper initialization.

**Example:**
```lua
exports['vmenu']:CreateMenu('my-custom-menu', 'Custom Menu', 'My Plugin Menu', function()
    print('Menu opened!')
end)
```

---

### OpenMenu

Opens a menu by ID (works with both custom and built-in vMenu menus).

**Syntax:**
```lua
exports['vmenu']:OpenMenu(menuId)
```

**Parameters:**
- `menuId` (string, required): Menu identifier

**Example:**
```lua
exports['vmenu']:OpenMenu('my-custom-menu')
exports['vmenu']:OpenMenu('player-options') -- Opens built-in menu
```

---

### CloseMenu

Closes a specific menu.

**Syntax:**
```lua
exports['vmenu']:CloseMenu(menuId)
```

**Parameters:**
- `menuId` (string, required): Menu identifier

**Example:**
```lua
exports['vmenu']:CloseMenu('my-custom-menu')
```

---

### CloseAllMenus

Closes all open menus.

**Syntax:**
```lua
exports['vmenu']:CloseAllMenus()
```

**Example:**
```lua
exports['vmenu']:CloseAllMenus()
```

---

### CheckMenu

Checks if a menu exists.

**Syntax:**
```lua
local exists = exports['vmenu']:CheckMenu(menuId)
```

**Parameters:**
- `menuId` (string, required): Menu identifier

**Returns:**
- `boolean`: True if menu exists, false otherwise

**Example:**
```lua
if exports['vmenu']:CheckMenu('my-custom-menu') then
    print('Menu exists!')
end
```

---

### ClearMenu

Removes all items from a menu.

**Syntax:**
```lua
exports['vmenu']:ClearMenu(menuId)
```

**Parameters:**
- `menuId` (string, required): Menu identifier

**Example:**
```lua
exports['vmenu']:ClearMenu('my-custom-menu')
```

---

### RefreshMenu

Refreshes a menu's display (useful after adding/removing items).

**Syntax:**
```lua
exports['vmenu']:RefreshMenu(menuId)
```

**Parameters:**
- `menuId` (string, required): Menu identifier

**Example:**
```lua
exports['vmenu']:RefreshMenu('my-custom-menu')
```

---

### DeleteMenu

Permanently deletes a dynamic menu (only works with menus created via CreateMenu).

**Syntax:**
```lua
exports['vmenu']:DeleteMenu(menuId)
```

**Parameters:**
- `menuId` (string, required): Menu identifier

**Example:**
```lua
exports['vmenu']:DeleteMenu('my-custom-menu')
```

---

### GetAllMenuIds

Returns all available menu IDs (both custom and built-in).

**Syntax:**
```lua
local menuIds = exports['vmenu']:GetAllMenuIds()
```

**Returns:**
- `string[]`: Array of menu IDs

**Example:**
```lua
local menus = exports['vmenu']:GetAllMenuIds()
for _, menuId in ipairs(menus) do
    print('Available menu: ' .. menuId)
end
```

---

## Menu Items

### AddButton

Adds a clickable button to a menu.

**Syntax:**
```lua
exports['vmenu']:AddButton(menuId, buttonId, buttonLabel, buttonDescription, rightLabel, callback)
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
exports['vmenu']:AddButton('my-custom-menu', 'test-button', 'Click Me', 'This is a test button', '→', function()
    print('Button clicked!')
end)
```

**Legacy Syntax (still supported):**
```lua
exports['vmenu']:AddButton(menuId, buttonId, buttonLabel, buttonDescription, callback)
```

---

### AddList

Adds a scrollable list item to a menu.

**Syntax:**
```lua
exports['vmenu']:AddList(menuId, listId, listLabel, options, defaultIndex, description, callback)
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
exports['vmenu']:AddList('my-custom-menu', 'test-list', 'Choose Option', options, 0, 'Select an option', function(selected, value, index, oldIndex)
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
exports['vmenu']:AddCheckbox(menuId, checkboxId, checkboxLabel, description, defaultValue, callback)
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
exports['vmenu']:AddCheckbox('my-custom-menu', 'test-checkbox', 'Enable Feature', 'Toggle this feature', false, function(checked)
    print('Checkbox is now: ' .. tostring(checked))
end)
```

---

### AddSlider

Adds a slider item to a menu (0-10 range, representing 0-100%).

**Syntax:**
```lua
exports['vmenu']:AddSlider(menuId, sliderId, sliderLabel, description, defaultValue, callback)
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
exports['vmenu']:AddSlider('my-custom-menu', 'volume-slider', 'Volume', 'Adjust volume level', 5, function(oldPos, newPos)
    local percentage = (newPos / 10) * 100
    print('Volume: ' .. percentage .. '%')
end)
```

---

### AddSpacer

Adds a spacer/separator to a menu.

**Syntax:**
```lua
exports['vmenu']:AddSpacer(menuId, spacerId, spacerText, description)
```

**Parameters:**
- `menuId` (string, required): Target menu ID
- `spacerId` (string, required): Unique spacer identifier
- `spacerText` (string, optional): Spacer text (default: "---")
- `description` (string, optional): Description text (default: "")

**Example:**
```lua
exports['vmenu']:AddSpacer('my-custom-menu', 'section-1', '~b~Section 1', '')
```

---

### AddSubmenuButton

Adds a button that links to another menu (creates submenu navigation).

**Syntax:**
```lua
exports['vmenu']:AddSubmenuButton(parentMenuId, buttonId, submenuId, buttonLabel, buttonDescription, callback)
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
exports['vmenu']:CreateMenu('parent-menu', 'Parent Menu', 'Main Menu')
exports['vmenu']:CreateMenu('child-menu', 'Child Menu', 'Submenu')

-- Link them together
exports['vmenu']:AddSubmenuButton('parent-menu', 'child-button', 'child-menu', 'Open Submenu', 'Opens the child menu')
```

---

### RemoveItem

Removes an item from a menu by ID or index.

**Syntax:**
```lua
exports['vmenu']:RemoveItem(menuId, itemIdOrIndex)
```

**Parameters:**
- `menuId` (string, required): Target menu ID
- `itemIdOrIndex` (string|number, required): Item ID or index (0-based)

**Example:**
```lua
-- Remove by ID
exports['vmenu']:RemoveItem('my-custom-menu', 'test-button')

-- Remove by index
exports['vmenu']:RemoveItem('my-custom-menu', 0)
```

---

## Utilities

### Notify

Displays a notification to the player.

**Syntax:**
```lua
exports['vmenu']:Notify(message, type)
```

**Parameters:**
- `message` (string, required): Notification text
- `type` (string, optional): Notification type: "error", "info", "success", or default

**Example:**
```lua
exports['vmenu']:Notify('Hello World!', 'info')
exports['vmenu']:Notify('Something went wrong!', 'error')
exports['vmenu']:Notify('Task completed!', 'success')
exports['vmenu']:Notify('Default notification')
```

---

## Examples

### Complete Plugin Example (Lua)

```lua
local resourceName = GetCurrentResourceName()

function initializePlugin()
    -- Create main menu
    exports['vmenu']:CreateMenu('my-plugin', 'My Plugin', 'Example Plugin Menu', function()
        print('My Plugin menu opened!')
    end)

-- Add a button
exports['vmenu']:AddButton('my-plugin', 'spawn-vehicle', 'Spawn Vehicle', 'Spawns a vehicle', nil, function()
    local vehicleHash = GetHashKey('adder')
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
        Wait(0)
    end

    local vehicle = CreateVehicle(vehicleHash, coords.x, coords.y, coords.z, GetEntityHeading(playerPed), true, false)
    SetPedIntoVehicle(playerPed, vehicle, -1)

    exports['vmenu']:Notify('Vehicle spawned!', 'success')
end)

-- Add a checkbox
local godModeEnabled = false
exports['vmenu']:AddCheckbox('my-plugin', 'godmode-toggle', 'God Mode', 'Toggle invincibility', false, function(checked)
    godModeEnabled = checked
    SetEntityInvincible(PlayerPedId(), checked)
    exports['vmenu']:Notify('God Mode: ' .. tostring(checked), 'info')
end)

-- Add a list
local weaponList = {'WEAPON_PISTOL', 'WEAPON_SMG', 'WEAPON_RIFLE'}
local weaponNames = {'Pistol', 'SMG', 'Rifle'}
exports['vmenu']:AddList('my-plugin', 'weapon-list', 'Give Weapon', weaponNames, 0, 'Select a weapon', function(selected, value, index)
    if selected then
        GiveWeaponToPed(PlayerPedId(), GetHashKey(weaponList[index + 1]), 250, false, true)
        exports['vmenu']:Notify('Given: ' .. value, 'success')
    end
end)

-- Add submenu
exports['vmenu']:CreateMenu('my-plugin-settings', 'Settings', 'Plugin Settings')
exports['vmenu']:AddSubmenuButton('my-plugin', 'settings-btn', 'my-plugin-settings', 'Settings', 'Configure plugin')

-- Add items to submenu
exports['vmenu']:AddCheckbox('my-plugin-settings', 'auto-heal', 'Auto Heal', 'Automatically heal player', false, function(checked)
    print('Auto heal: ' .. tostring(checked))
end)

    -- Command to open menu
    RegisterCommand('myplugin', function()
        exports['vmenu']:OpenMenu('my-plugin')
    end, false)
end

-- Initialize after vMenu is ready (see "Menu Initialization Timing" section)
AddEventHandler("vMenu:SetupTickFunctions", function()
    Citizen.Wait(100)
    initializePlugin()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == resourceName then
        if exports.vMenu and exports.vMenu:CheckMenu("main-menu") then
            Citizen.Wait(1000)
            initializePlugin()
        end
    end
end)
```

### Adding to Built-in vMenu Menus

```lua
-- Add items to existing vMenu menus
RegisterNetEvent('vMenu:client:ready', function()
    -- Wait a bit for vMenu to fully initialize
    Wait(1000)

    -- Add a button to the Vehicle Options menu
    if exports['vmenu']:CheckMenu('vehicle-options') then
        exports['vmenu']:AddButton('vehicle-options', 'custom-paint', 'Custom Paint Job', 'Apply custom paint', nil, function()
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if vehicle ~= 0 then
                SetVehicleCustomPrimaryColour(vehicle, 255, 0, 0)
                SetVehicleCustomSecondaryColour(vehicle, 0, 0, 255)
                exports['vmenu']:Notify('Custom paint applied!', 'success')
            end
        end)
    end
end)
```

### Dynamic Menu Creation

```lua
-- Create a menu dynamically based on server data
RegisterNetEvent('myresource:showVehicleMenu', function(vehicles)
    -- Create menu if it doesn't exist
    if not exports['vmenu']:CheckMenu('vehicle-catalog') then
        exports['vmenu']:CreateMenu('vehicle-catalog', 'Vehicle Catalog', 'Available Vehicles')
    else
        exports['vmenu']:ClearMenu('vehicle-catalog')
    end

    -- Add vehicles dynamically
    for i, vehicle in ipairs(vehicles) do
        exports['vmenu']:AddButton('vehicle-catalog', 'vehicle-' .. i, vehicle.name, vehicle.description, '$' .. vehicle.price, function()
            TriggerServerEvent('myresource:purchaseVehicle', vehicle.id)
        end)
    end

    -- Open the menu
    exports['vmenu']:OpenMenu('vehicle-catalog')
end)
```

---

## Built-in Menu IDs

Common built-in vMenu menus you can extend:

- `player-options` - Player Options menu
- `online-players` - Online Players menu
- `vehicle-options` - Vehicle Options menu
- `vehicle-spawner` - Vehicle Spawner menu
- `player-appearance` - Player Appearance menu
- `weapon-options` - Weapon Options menu
- `time-options` - Time Options menu (if enabled)
- `weather-options` - Weather Options menu (if enabled)
- `voice-chat-settings` - Voice Chat Settings menu
- `misc-settings` - Miscellaneous Settings menu

Use `GetAllMenuIds()` to get a complete list of available menus at runtime.
