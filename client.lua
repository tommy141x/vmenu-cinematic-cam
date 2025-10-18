--[[
    Cinematic Camera Script for vMenu
    by Tommy141x
]]

local Config             = {}

----------------------
-- General settings --
----------------------
Config.maxDistance       = 500.0
Config.disableAttach     = false

-- Movement speed settings
Config.minMoveSpeed      = 0.1
Config.incrMoveSpeed     = 0.1
Config.maxMoveSpeed      = 1.0
Config.moveSpeedMultiplier = 0.05

-- Rotation sensitivity settings
Config.minPrecision      = 0.1
Config.incrPrecision     = 0.1
Config.maxPrecision      = 1.0
Config.rotationMultiplier = 3.0

Config.minFov            = 1.0
Config.maxFov            = 130.0

-- Smoothness settings
Config.minSmoothness     = 0.0
Config.incrSmoothness    = 0.1
Config.maxSmoothness     = 1.0

Config.menuTitle         = "Cinematic Cam"
Config.menuSubtitle      = "Cinematic Camera"
Config.toggleCam         = "Camera Active"
Config.toggleCamDesc     = "Toggle camera on/off"
Config.moveSpeed         = "Movement Speed"
Config.moveSpeedDesc     = "Change camera movement speed"
Config.precision         = "Rotation Sensitivity"
Config.precisionDesc     = "Change camera rotation sensitivity (Enter to reset roll)"
Config.smoothness        = "Camera Smoothness"
Config.smoothnessDesc    = "0 = instant, 1 = ultra smooth"
Config.showMap           = "Toggle Hud"
Config.showMapDesc       = "Toggle HUD on/off"
Config.charControl       = "Toggle Character Control"
Config.charControlDesc   = "Switch to Character or back to Camera Control"
Config.attachCam         = "Attach to Entity"
Config.attachCamDesc     = "Attach the Camera to the entity in front of the camera"
Config.dof               = "Depth of Field"
Config.dofDesc           = "Adjust DOF focus range (Enter to toggle on/off)"

-- Disabled controls
Config.disabledControls  = {
    30, 31, 21, 36, 22, 44, 38, 71, 72, 59, 60, 85, 86, 15, 14, 178
}

-- Camera variables
local cam                = nil
local targetPosX         = 0.0
local targetPosY         = 0.0
local targetPosZ         = 0.0
local currentPosX        = 0.0
local currentPosY        = 0.0
local currentPosZ        = 0.0

local targetRotX         = 0.0
local targetRotY         = 0.0
local targetRotZ         = 0.0
local currentRotX        = 0.0
local currentRotY        = 0.0
local currentRotZ        = 0.0

local targetFov          = 0.0
local currentFov         = 0.0

local targetDof          = 0.0
local currentDof         = 0.0
local dofEnabled         = false

local moveSpeed          = 0.5
local precision          = 0.5
local smoothness         = 0.5
local charControl        = false
local isAttached         = false
local entity             = nil
local offsetCoords       = { x = 0.0, y = 0.0, z = 0.0 }
local useNativeAttach    = false  -- Use native attachment when smoothness = 0.0

-- Key states
local keyStates = {
    forwards = false,
    backwards = false,
    left = false,
    right = false,
    up = false,
    down = false,
    rollLeft = false,
    rollRight = false,
    holdShift = false
}

-- Prepare movement speed list
local moveSpeeds         = {}
local counter            = 0
local currMoveSpeedIndex = 1

for i = Config.minMoveSpeed, Config.maxMoveSpeed + 0.01, Config.incrMoveSpeed do
    table.insert(moveSpeeds, string.format("%.1f", i))
    counter = counter + 1
    if (math.abs(i - 0.5) < 0.01) then
        currMoveSpeedIndex = counter
        moveSpeed = i
    end
end

-- Prepare precision list
local precisions         = {}
counter                  = 0
local currPrecisionIndex = 1

for i = Config.minPrecision, Config.maxPrecision + 0.01, Config.incrPrecision do
    table.insert(precisions, string.format("%.1f", i))
    counter = counter + 1
    if (math.abs(i - 0.5) < 0.01) then
        currPrecisionIndex = counter
        precision = i
    end
end

-- Prepare DOF list (0.0 to 1.0 in increments of 0.1)
local dofValues          = {}
counter                  = 0
local currDofIndex       = 1

for i = 0.0, 1.0 + 0.01, 0.1 do
    table.insert(dofValues, string.format("%.1f", i))
    counter = counter + 1
    if (math.abs(i - 0.5) < 0.01) then
        currDofIndex = counter
        targetDof = i
        currentDof = i
    end
end

-- Prepare smoothness list
local smoothnesses       = {}
counter                  = 0
local currSmoothnessIndex = 1

for i = Config.minSmoothness, Config.maxSmoothness + 0.01, Config.incrSmoothness do
    table.insert(smoothnesses, string.format("%.1f", i))
    counter = counter + 1
    if (math.abs(i - 0.5) < 0.01) then
        currSmoothnessIndex = counter
        smoothness = i
    end
end

--------------------------------------------------
----------- REGISTER KEY MAPPINGS ----------------
--------------------------------------------------

RegisterCommand('+cam_forward', function() keyStates.forwards = true end, false)
RegisterCommand('-cam_forward', function() keyStates.forwards = false end, false)
RegisterKeyMapping('+cam_forward', 'Camera: Move Forward', 'keyboard', 'w')

RegisterCommand('+cam_backward', function() keyStates.backwards = true end, false)
RegisterCommand('-cam_backward', function() keyStates.backwards = false end, false)
RegisterKeyMapping('+cam_backward', 'Camera: Move Backward', 'keyboard', 's')

RegisterCommand('+cam_left', function() keyStates.left = true end, false)
RegisterCommand('-cam_left', function() keyStates.left = false end, false)
RegisterKeyMapping('+cam_left', 'Camera: Move Left', 'keyboard', 'a')

RegisterCommand('+cam_right', function() keyStates.right = true end, false)
RegisterCommand('-cam_right', function() keyStates.right = false end, false)
RegisterKeyMapping('+cam_right', 'Camera: Move Right', 'keyboard', 'd')

RegisterCommand('+cam_up', function() keyStates.up = true end, false)
RegisterCommand('-cam_up', function() keyStates.up = false end, false)
RegisterKeyMapping('+cam_up', 'Camera: Move Up', 'keyboard', 'SPACE')

RegisterCommand('+cam_down', function() keyStates.down = true end, false)
RegisterCommand('-cam_down', function() keyStates.down = false end, false)
RegisterKeyMapping('+cam_down', 'Camera: Move Down', 'keyboard', 'LCONTROL')

RegisterCommand('+cam_roll_left', function() keyStates.rollLeft = true end, false)
RegisterCommand('-cam_roll_left', function() keyStates.rollLeft = false end, false)
RegisterKeyMapping('+cam_roll_left', 'Camera: Roll Left', 'keyboard', 'q')

RegisterCommand('+cam_roll_right', function() keyStates.rollRight = true end, false)
RegisterCommand('-cam_roll_right', function() keyStates.rollRight = false end, false)
RegisterKeyMapping('+cam_roll_right', 'Camera: Roll Right', 'keyboard', 'e')

RegisterCommand('+cam_shift', function() keyStates.holdShift = true end, false)
RegisterCommand('-cam_shift', function() keyStates.holdShift = false end, false)
RegisterKeyMapping('+cam_shift', 'Camera: Hold for Speed Control', 'keyboard', 'LSHIFT')

-- Command to open the cinematic camera menu
RegisterCommand('cinecam', function()
    exports["vMenu"]:OpenMenu("cinematic_cam")
end, false)

--------------------------------------------------
--------------- MENU CREATION --------------------
--------------------------------------------------

function createCinematicCamMenu()
    exports["vMenu"]:CreateMenu("cinematic_cam", Config.menuTitle, Config.menuSubtitle)
    exports["vMenu"]:ClearMenu("cinematic_cam")

    exports["vMenu"]:AddCheckbox("cinematic_cam", "toggle_cam", Config.toggleCam,
        Config.toggleCamDesc, false, function(isChecked)
            ToggleCam(isChecked, GetGameplayCamFov())
        end)

    exports["vMenu"]:AddList("cinematic_cam", "move_speed", Config.moveSpeed,
        moveSpeeds, currMoveSpeedIndex - 1, Config.moveSpeedDesc,
        function(isSelected, currentValue, currentIndex, previousIndex)
            moveSpeed = tonumber(currentValue)
        end)

    exports["vMenu"]:AddList("cinematic_cam", "cam_precision", Config.precision,
        precisions, currPrecisionIndex - 1, Config.precisionDesc,
        function(isSelected, currentValue, currentIndex, previousIndex)
            precision = tonumber(currentValue)
            -- If Enter was pressed, reset camera roll to level
            if isSelected then
                if isAttached then
                    offsetCoords.rotY = 0
                    exports["vMenu"]:Notify("Camera roll reset", "success")
                else
                    targetRotY = 0
                    exports["vMenu"]:Notify("Camera roll reset", "success")
                end
            end
        end)

    exports["vMenu"]:AddList("cinematic_cam", "smoothness", Config.smoothness,
        smoothnesses, currSmoothnessIndex - 1, Config.smoothnessDesc,
        function(isSelected, currentValue, currentIndex, previousIndex)
            smoothness = tonumber(currentValue)
            -- If attached and smoothness changed to/from 0.0, update attachment mode
            if isAttached and DoesEntityExist(entity) then
                if smoothness == 0.0 and not useNativeAttach then
                    -- Switch to native attach
                    useNativeAttach = true
                    AttachCamToEntity(cam, entity, offsetCoords.x, offsetCoords.y, offsetCoords.z, true)
                elseif smoothness > 0.0 and useNativeAttach then
                    -- Switch to smooth lerp
                    useNativeAttach = false
                    DetachCam(cam)
                end
            end
        end)

    exports["vMenu"]:AddList("cinematic_cam", "dof", Config.dof,
        dofValues, currDofIndex - 1, Config.dofDesc,
        function(isSelected, currentValue, currentIndex, previousIndex)
            local newDof = tonumber(currentValue)
            -- If Enter was pressed, toggle DOF on/off
            if isSelected then
                dofEnabled = not dofEnabled
                if dofEnabled then
                    exports["vMenu"]:Notify("DOF enabled", "success")
                else
                    exports["vMenu"]:Notify("DOF disabled", "info")
                end
            else
                targetDof = newDof
            end
        end)

    exports["vMenu"]:AddCheckbox("cinematic_cam", "show_map", Config.showMap,
        Config.showMapDesc, true, function(isChecked)
            ToggleUI(isChecked)
        end)

    exports["vMenu"]:AddCheckbox("cinematic_cam", "char_control", Config.charControl,
        Config.charControlDesc, charControl, function(isChecked)
            ToggleCharacterControl(isChecked)
        end)

    if not Config.disableAttach then
        exports["vMenu"]:AddButton("cinematic_cam", "attach_camera", Config.attachCam,
            Config.attachCamDesc, function()
                ToggleAttachMode()
            end)
    end
end

--------------------------------------------------
--------------- MAIN THREADS ---------------------
--------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if (cam) then
            ProcessCamControls()
        else
            Citizen.Wait(500)
        end
    end
end)

if (not Config.disableAttach) then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500)
            if (cam) then
                if (isAttached and not DoesEntityExist(entity)) then
                    isAttached = false
                    ClearFocus()
                    StopCamPointing(cam)
                end
            end
        end
    end)
end

--------------------------------------------------
------------------- FUNCTIONS --------------------
--------------------------------------------------

function StartFreeCam(fov)
    ClearFocus()

    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)

    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", playerPos.x, playerPos.y, playerPos.z, 0, 0, 0, fov * 1.0)

    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)
    SetCamAffectsAiming(cam, false)

    -- Initialize position and rotation
    currentPosX = playerPos.x
    currentPosY = playerPos.y
    currentPosZ = playerPos.z
    targetPosX = playerPos.x
    targetPosY = playerPos.y
    targetPosZ = playerPos.z

    currentRotX = 0.0
    currentRotY = 0.0
    currentRotZ = 0.0
    targetRotX = 0.0
    targetRotY = 0.0
    targetRotZ = 0.0

    targetFov = fov
    currentFov = fov

    targetDof = 0.5
    currentDof = 0.5
    dofEnabled = false

    if (Config.disableAttach) then
        ToggleAttachMode(PlayerPedId())
    end

    if (isAttached and DoesEntityExist(entity)) then
        offsetCoords = GetOffsetFromEntityGivenWorldCoords(entity, GetCamCoord(cam))
        AttachCamToEntity(cam, entity, offsetCoords.x, offsetCoords.y, offsetCoords.z, true)
    end
end

function EndFreeCam()
    ClearFocus()

    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cam, false)

    isAttached = false
    moveSpeed  = 0.5
    currFov    = GetGameplayCamFov()

    cam        = nil
end

function ProcessCamControls()
    local playerPed = PlayerPedId()

    DisableFirstPersonCamThisFrame()
    BlockWeaponWheelThisFrame()

    if (not charControl) then
        for k, v in pairs(Config.disabledControls) do
            DisableControlAction(0, v, true)
        end
    end

    -- Update target position and rotation
    if (isAttached and DoesEntityExist(entity)) then
        -- Attach mode: always follow entity (even with character control on)
        local entityPos = GetEntityCoords(entity)
        local entityRot = GetEntityRotation(entity, 2)

        -- If smoothness is 0.0, use native attachment
        if smoothness == 0.0 then
            if not useNativeAttach then
                useNativeAttach = true
                AttachCamToEntity(cam, entity, offsetCoords.x, offsetCoords.y, offsetCoords.z, true)
            end
        else
            if useNativeAttach then
                useNativeAttach = false
                DetachCam(cam)
            end
        end

        -- Only accept input to change offset if character control is OFF
        if (not charControl) then
        local forwardInput = 0.0
        local rightInput = 0.0
        local upInput = 0.0

        if keyStates.forwards then forwardInput = forwardInput + 1.0 end
        if keyStates.backwards then forwardInput = forwardInput - 1.0 end
        if keyStates.left then rightInput = rightInput - 1.0 end
        if keyStates.right then rightInput = rightInput + 1.0 end
        if keyStates.up then upInput = upInput + 1.0 end
        if keyStates.down then upInput = upInput - 1.0 end

        -- Normalize input
        local inputMagnitude = math.sqrt(forwardInput * forwardInput + rightInput * rightInput + upInput * upInput)
        if inputMagnitude > 0.0 then
            forwardInput = forwardInput / inputMagnitude
            rightInput = rightInput / inputMagnitude
            upInput = upInput / inputMagnitude
        end

            -- Update offset with input (in local space - forward = +Y, right = +X in local coords)
            -- Update offset with input (relative to camera rotation, not entity)
            local actualMoveSpeed = moveSpeed * Config.moveSpeedMultiplier
            if inputMagnitude > 0.0 then
                -- Calculate current camera world rotation (entity + offset for proper input direction)
                local currentCamRotZ = entityRot.z + (offsetCoords.rotZ or 0)

                -- Calculate input direction in world space based on CURRENT camera rotation
                local forwardX = -math.sin(math.rad(currentCamRotZ))
                local forwardY = math.cos(math.rad(currentCamRotZ))
                local rightX = math.sin(math.rad(currentCamRotZ + 90.0))
                local rightY = -math.cos(math.rad(currentCamRotZ + 90.0))

                local worldInputX = ((forwardX * forwardInput) + (rightX * rightInput)) * actualMoveSpeed
                local worldInputY = ((forwardY * forwardInput) + (rightY * rightInput)) * actualMoveSpeed
                local worldInputZ = upInput * actualMoveSpeed

                -- Convert world input to entity's local space
                local radZ = math.rad(entityRot.z)
                local cosZ = math.cos(radZ)
                local sinZ = math.sin(radZ)

                local localInputX = (worldInputX * cosZ + worldInputY * sinZ)
                local localInputY = (-worldInputX * sinZ + worldInputY * cosZ)

                -- Apply to offset (which is in local space)
                offsetCoords.x = offsetCoords.x + localInputX
                offsetCoords.y = offsetCoords.y + localInputY
                offsetCoords.z = offsetCoords.z + worldInputZ
            end

            -- Update rotation offset
            local mouseX = GetDisabledControlNormal(1, 1)
            local mouseY = GetDisabledControlNormal(1, 2)
            local actualPrecision = precision * Config.rotationMultiplier
            offsetCoords.rotX = (offsetCoords.rotX or 0) - (mouseY * actualPrecision)
            offsetCoords.rotZ = (offsetCoords.rotZ or 0) - (mouseX * actualPrecision)

            -- Roll controls
            local rollSpeed = actualPrecision * 0.3
            if keyStates.rollLeft then
                offsetCoords.rotY = (offsetCoords.rotY or 0) - rollSpeed
            elseif keyStates.rollRight then
                offsetCoords.rotY = (offsetCoords.rotY or 0) + rollSpeed
            end

            -- Clamp rotation offsets
            if offsetCoords.rotX and offsetCoords.rotX > 90.0 then offsetCoords.rotX = 90.0 elseif offsetCoords.rotX and offsetCoords.rotX < -90.0 then offsetCoords.rotX = -90.0 end
            if offsetCoords.rotY and offsetCoords.rotY > 90.0 then offsetCoords.rotY = 90.0 elseif offsetCoords.rotY and offsetCoords.rotY < -90.0 then offsetCoords.rotY = -90.0 end
        end

        -- Convert offset from local space to world space using entity rotation
        local radZ = math.rad(entityRot.z)
        local cosZ = math.cos(radZ)
        local sinZ = math.sin(radZ)

        -- Rotate offset vector by entity's rotation
        local worldOffsetX = (offsetCoords.x * cosZ - offsetCoords.y * sinZ)
        local worldOffsetY = (offsetCoords.x * sinZ + offsetCoords.y * cosZ)

        -- Set target to entity + rotated offset (always, even with character control on)
        targetPosX = entityPos.x + worldOffsetX
        targetPosY = entityPos.y + worldOffsetY
        targetPosZ = entityPos.z + offsetCoords.z

        targetRotX = entityRot.x + (offsetCoords.rotX or 0)
        targetRotY = entityRot.y + (offsetCoords.rotY or 0)
        targetRotZ = entityRot.z + (offsetCoords.rotZ or 0)
    elseif (not charControl) then
        -- Free mode: only update if character control is OFF
        local forwardInput = 0.0
        local rightInput = 0.0
        local upInput = 0.0

        if keyStates.forwards then forwardInput = forwardInput + 1.0 end
        if keyStates.backwards then forwardInput = forwardInput - 1.0 end
        if keyStates.left then rightInput = rightInput - 1.0 end
        if keyStates.right then rightInput = rightInput + 1.0 end
        if keyStates.up then upInput = upInput + 1.0 end
        if keyStates.down then upInput = upInput - 1.0 end

        -- Normalize input
        local inputMagnitude = math.sqrt(forwardInput * forwardInput + rightInput * rightInput + upInput * upInput)
        if inputMagnitude > 0.0 then
            forwardInput = forwardInput / inputMagnitude
            rightInput = rightInput / inputMagnitude
            upInput = upInput / inputMagnitude
        end

        local actualMoveSpeed = moveSpeed * Config.moveSpeedMultiplier
        if inputMagnitude > 0.0 then
                local forwardX = -math.sin(math.rad(currentRotZ))
                local forwardY = math.cos(math.rad(currentRotZ))
                local rightX = math.sin(math.rad(currentRotZ + 90.0))
                local rightY = -math.cos(math.rad(currentRotZ + 90.0))

                targetPosX = targetPosX + ((forwardX * forwardInput) + (rightX * rightInput)) * actualMoveSpeed
                targetPosY = targetPosY + ((forwardY * forwardInput) + (rightY * rightInput)) * actualMoveSpeed
            targetPosZ = targetPosZ + upInput * actualMoveSpeed
        end

        -- Update target rotation
        local mouseX = GetDisabledControlNormal(1, 1)
        local mouseY = GetDisabledControlNormal(1, 2)
        local actualPrecision = precision * Config.rotationMultiplier
            targetRotX = targetRotX - (mouseY * actualPrecision)
        targetRotZ = targetRotZ - (mouseX * actualPrecision)

        -- Roll controls
        local rollSpeed = actualPrecision * 0.3
        if keyStates.rollLeft then
                targetRotY = targetRotY - rollSpeed
            elseif keyStates.rollRight then
            targetRotY = targetRotY + rollSpeed
        end

        -- Clamp rotation
        if targetRotX > 90.0 then targetRotX = 90.0 elseif targetRotX < -90.0 then targetRotX = -90.0 end
        if targetRotY > 90.0 then targetRotY = 90.0 elseif targetRotY < -90.0 then targetRotY = -90.0 end
        if targetRotZ > 360.0 then
            targetRotZ = targetRotZ - 360.0
        elseif targetRotZ < -360.0 then
            targetRotZ = targetRotZ + 360.0
        end
    end

    -- Exponential damping: speed is proportional to distance from target
    -- Skip smoothing if using native attachment
    if not useNativeAttach then
        -- The further from target, the faster we move. The closer, the slower.
        -- Smoothness controls the damping coefficient (how quickly we approach)
        -- Use square root curve for more effect at low values, gradual change at high values
        -- Map smoothness 0.0→1.0 to damping 0.3→0.005 with sqrt curve (starts lower for noticeable smoothing)
        local smoothnessCurve = math.sqrt(smoothness)  -- Square root for inverse curve
        local damping = 0.3 - (smoothnessCurve * 0.295)  -- Range: 0.3 to 0.005

        -- For exponential damping, we use: current = target + (current - target) * (1 - damping)
        -- This naturally slows as we approach the target
        currentPosX = targetPosX + (currentPosX - targetPosX) * (1.0 - damping)
        currentPosY = targetPosY + (currentPosY - targetPosY) * (1.0 - damping)
        currentPosZ = targetPosZ + (currentPosZ - targetPosZ) * (1.0 - damping)

        currentRotX = targetRotX + (currentRotX - targetRotX) * (1.0 - damping)
        currentRotY = targetRotY + (currentRotY - targetRotY) * (1.0 - damping)
        currentRotZ = targetRotZ + (currentRotZ - targetRotZ) * (1.0 - damping)
    end

    -- Apply to camera
    if useNativeAttach then
        -- Native attachment: manually set rotation and update attachment with new offset
        SetCamRot(cam, targetRotX, targetRotY, targetRotZ, 2)
        AttachCamToEntity(cam, entity, offsetCoords.x, offsetCoords.y, offsetCoords.z, true)
    else
        if not isAttached then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(vector3(currentPosX, currentPosY, currentPosZ) - playerCoords)

            if (distance > Config.maxDistance) then
                local factor = distance / Config.maxDistance
                currentPosX = playerCoords.x + (currentPosX - playerCoords.x) / factor
                currentPosY = playerCoords.y + (currentPosY - playerCoords.y) / factor
                currentPosZ = playerCoords.z + (currentPosZ - playerCoords.z) / factor
                targetPosX = currentPosX
                targetPosY = currentPosY
                targetPosZ = currentPosZ
            end
        end

        SetFocusArea(currentPosX, currentPosY, currentPosZ, 0.0, 0.0, 0.0)
        SetCamCoord(cam, currentPosX, currentPosY, currentPosZ)
        SetCamRot(cam, currentRotX, currentRotY, currentRotZ, 2)
    end

    -- Speed and FOV controls
    if keyStates.holdShift then
        if IsDisabledControlPressed(1, 14) then
            if ((moveSpeed - 0.01) > Config.minMoveSpeed) then
                moveSpeed = moveSpeed - 0.01
            else
                moveSpeed = Config.minMoveSpeed
            end
        elseif IsDisabledControlPressed(1, 15) then
            if ((moveSpeed + 0.01) < Config.maxMoveSpeed) then
                moveSpeed = moveSpeed + 0.01
            else
                moveSpeed = Config.maxMoveSpeed
            end
        end
    else
        if IsDisabledControlPressed(1, 14) then
            targetFov = targetFov + 1.0
        elseif IsDisabledControlPressed(1, 15) then
            targetFov = targetFov - 1.0
        end

        -- Clamp target FOV
        if targetFov < Config.minFov then targetFov = Config.minFov end
        if targetFov > Config.maxFov then targetFov = Config.maxFov end

        -- Exponential damping for FOV with sqrt curve
        local smoothnessCurve = math.sqrt(smoothness)
        local damping = 0.3 - (smoothnessCurve * 0.295)
        currentFov = targetFov + (currentFov - targetFov) * (1.0 - damping)
        SetCamFov(cam, currentFov)

        -- Exponential damping for DOF with sqrt curve
        currentDof = targetDof + (currentDof - targetDof) * (1.0 - damping)

        -- Apply DOF to camera if enabled
        if dofEnabled then
            SetCamUseShallowDofMode(cam, true)
            SetCamNearDof(cam, 0.5)
            -- Scale far DOF based on value: 0.0 = tight focus (2.5 units), 1.0 = wide focus (50 units)
            SetCamFarDof(cam, 0.5 + (currentDof * 49.5))
            SetCamDofStrength(cam, 1.0)
            SetUseHiDof()
        else
            -- Disable DOF
            SetCamUseShallowDofMode(cam, false)
            SetCamDofStrength(cam, 0.0)
        end
    end
end

function ToggleCam(flag, fov)
    if (flag) then
        StartFreeCam(fov)
    else
        EndFreeCam()
    end
end

function ChangeFov(changeFov)
    -- Legacy function for compatibility
    if (DoesCamExist(cam)) then
        targetFov = targetFov + changeFov
        if targetFov < Config.minFov then targetFov = Config.minFov end
        if targetFov > Config.maxFov then targetFov = Config.maxFov end
    end
end

function ToggleUI(flag)
    DisplayRadar(flag)
    TriggerEvent('hudtoggle', flag)
end

function GetEntityInFrontOfCam()
    local offset = {
        x = currentPosX - math.sin(math.rad(currentRotZ)) * 100.0,
        y = currentPosY + math.cos(math.rad(currentRotZ)) * 100.0,
        z = currentPosZ + math.sin(math.rad(currentRotX)) * 100.0
    }

    local rayHandle = StartShapeTestRay(currentPosX, currentPosY, currentPosZ, offset.x, offset.y, offset.z, 10, 0, 0)
    local a, b, c, d, entity = GetShapeTestResult(rayHandle)
    return entity
end

function ToggleCharacterControl(flag)
    charControl = flag
end

function ToggleAttachMode(playerEntity)
    if (not isAttached) then
        -- Try to get entity in this order: 1) provided entity, 2) player's vehicle, 3) entity in front of cam
        if playerEntity then
            entity = playerEntity
        else
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                entity = GetVehiclePedIsIn(playerPed, false)
            else
                entity = GetEntityInFrontOfCam()
            end
        end

        if (DoesEntityExist(entity) and entity ~= 0) then
            -- Calculate offset from entity to current camera position in local space
            local entityPos = GetEntityCoords(entity)
            local entityRot = GetEntityRotation(entity, 2)

            -- Convert world offset to local space
            local worldOffsetX = currentPosX - entityPos.x
            local worldOffsetY = currentPosY - entityPos.y

            local radZ = math.rad(entityRot.z)
            local cosZ = math.cos(radZ)
            local sinZ = math.sin(radZ)

            -- Rotate world offset back to local space
            offsetCoords.x = (worldOffsetX * cosZ + worldOffsetY * sinZ)
            offsetCoords.y = (-worldOffsetX * sinZ + worldOffsetY * cosZ)
            offsetCoords.z = currentPosZ - entityPos.z

            -- Initialize rotation offsets to 0
            offsetCoords.rotX = 0
            offsetCoords.rotY = 0
            offsetCoords.rotZ = 0

            isAttached = true

            -- If smoothness is 0.0, use native attachment immediately
            if smoothness == 0.0 then
                useNativeAttach = true
                AttachCamToEntity(cam, entity, offsetCoords.x, offsetCoords.y, offsetCoords.z, true)
            else
                useNativeAttach = false
            end

            exports["vMenu"]:Notify("Camera attached to entity", "success")
        else
            exports["vMenu"]:Notify("No entity found to attach to", "error")
        end
    else
        ClearFocus()

        -- Detach native cam if it was attached
        if useNativeAttach then
            DetachCam(cam)
            useNativeAttach = false
        end

        isAttached = false
        offsetCoords = { x = 0.0, y = 0.0, z = 0.0 }
        exports["vMenu"]:Notify("Camera detached", "info")
    end
end

createCinematicCamMenu()
