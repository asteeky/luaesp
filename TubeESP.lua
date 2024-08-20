local m_pGameSceneNode = GetOffset({"client.dll", "classes", "C_BaseEntity", "fields", "m_pGameSceneNode"}, "client.dll")
local m_vecAbsOrigin = GetOffset({"client.dll", "classes", "CGameSceneNode", "fields", "m_vecAbsOrigin"}, "client.dll")
local m_modelState = GetOffset({"client.dll", "classes", "CSkeletonInstance", "fields", "m_modelState"}, "client.dll")
local m_iHealth = GetOffset({"client.dll", "classes", "C_BaseEntity", "fields", "m_iHealth"}, "client.dll")
 
ReserveMenuElement(8)
CheckBox("Tube ESP", false)
CheckBox("Skip Team", false)
CheckBox("Tube start and end", false)
ColorPicker("Enemy color", Color(255, 255, 255, 255))
ColorPicker("Team color", Color(255, 255, 255, 255))
SliderFloat("Speed", 1.0, 100.0, 5.0)
SliderFloat("Thickness", 1.0, 20.0, 5.0)
SliderFloat("Radius", 1.0, 100.0, 15.0)
 
Clear()
Print("Tube ESP Loaded")
 
local z_offset = 0
 
local function TubeESP()
    local teamColor = GetColorPicker("Team color")
    local enemyColor = GetColorPicker("Enemy color")
 
    local localInfo = GetLocalInfo()
    local entity_list = GetEntities()
 
    if not entity_list or #entity_list == 0 then
        return
    end
 
    for i = 1, #entity_list do
        if not GetCheckBox("Tube ESP") then
            goto continue
        end
 
        local entity = entity_list[i]
        if not entity or #entity < 1 then
            goto continue
        end
 
        local playerPawn = entity[1]
        if not playerPawn or playerPawn == 0 then
            goto continue
        end
 
        local GameSceneNode = ReadPointer(playerPawn + m_pGameSceneNode)
        if not GameSceneNode or GameSceneNode == 0 then
            goto continue
        end
 
        local vecAbsOrigin = ReadVector3D(GameSceneNode + m_vecAbsOrigin)
        if vecAbsOrigin[1] == 0 and vecAbsOrigin[2] == 0 and vecAbsOrigin[3] == 0 then
            goto continue
        end
 
        local boneArray = ReadPointer(GameSceneNode + m_modelState + 0x80)
        local bonePos = ReadVector3D(boneArray + 6 * 32)
        local ScreenPos = WorldToScreen(bonePos)
 
        if ScreenPos[1] == 0 and ScreenPos[2] == 0 then
            goto continue
        end
 
        local Health = ReadInt(playerPawn + m_iHealth)
        
        if Health > 0 then
            local z_range = math.floor(bonePos[3]+ 10.0) - vecAbsOrigin[3]
            local z = vecAbsOrigin[3] + (z_range / 2) * (1 + math.sin(z_offset))
            local radius = GetSliderFloat("Radius")
            local thickness = GetSliderFloat("Thickness")
 
            if localInfo[4] == entity[4] and not GetCheckBox("Skip Team") then
                Circle3D(Vector3D(vecAbsOrigin[1], vecAbsOrigin[2], z), radius, thickness, teamColor)
                
                if GetCheckBox("Tube start and end") == true then
                    Circle3D(vecAbsOrigin, radius, thickness, teamColor)
                    Circle3D(Vector3D(vecAbsOrigin[1], vecAbsOrigin[2], math.floor(bonePos[3]+ 10.0)), radius, thickness, teamColor)
                end
            elseif localInfo[4] ~= entity[4] then
                Circle3D(Vector3D(vecAbsOrigin[1], vecAbsOrigin[2], z), radius, thickness, enemyColor)
 
                if GetCheckBox("Tube start and end") == true then
                    Circle3D(vecAbsOrigin, radius, thickness, enemyColor)
                    Circle3D(Vector3D(vecAbsOrigin[1], vecAbsOrigin[2], math.floor(bonePos[3]+ 10.0)), radius, thickness, enemyColor)
                end
            end
        end
 
        ::continue::
    end
 
    z_offset = z_offset + GetSliderFloat("Speed") / 100
end
RegisterCallback(TubeESP)
