local m_pGameSceneNode = GetOffset({"client.dll", "classes", "C_BaseEntity", "fields", "m_pGameSceneNode"}, "client.dll")
local m_vecAbsOrigin = GetOffset({"client.dll", "classes", "CGameSceneNode", "fields", "m_vecAbsOrigin"}, "client.dll")
local m_modelState = GetOffset({"client.dll", "classes", "CSkeletonInstance", "fields", "m_modelState"}, "client.dll")
local ScreenCenter = Vector2D(math.floor(GetScreenSize()[1] / 2), math.floor(GetScreenSize()[2] / 2))
 
ReserveMenuElement(4) 
CheckBox("Line ESP", false)
CheckBox("Skip Team", false)
ColorPicker("Enemy color", Color(255, 255, 255, 255))
ColorPicker("Team color", Color(255, 255, 255, 255))
 
Clear()
Print("Line ESP Loaded")
 
local function LineESP()
    local teamColor = GetColorPicker("Team color")
    local enemyColor = GetColorPicker("Enemy color")
 
    local localInfo = GetLocalInfo()
    local entity_list = GetEntities()
    
    if not entity_list or #entity_list == 0 then
        return
    end
    
    for i = 1, #entity_list do
        if not GetCheckBox("Line ESP") then
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
 
        if localInfo[4] == entity[4] and not GetCheckBox("Skip Team") then
            Line(ScreenPos, Vector2D(ScreenCenter[1], ScreenCenter[2]), teamColor, 2.0)
        elseif localInfo[4] ~= entity[4] then
            Line(ScreenPos, Vector2D(ScreenCenter[1], ScreenCenter[2]), enemyColor, 2.0)
        end 
        
        ::continue::
    end
end
RegisterCallback(LineESP)
