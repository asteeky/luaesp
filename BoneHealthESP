local m_pGameSceneNode = GetOffset({"client.dll", "classes", "C_BaseEntity", "fields", "m_pGameSceneNode"}, "client.dll")
local m_vecAbsOrigin = GetOffset({"client.dll", "classes", "CGameSceneNode", "fields", "m_vecAbsOrigin"}, "client.dll")
local m_modelState = GetOffset({"client.dll", "classes", "CSkeletonInstance", "fields", "m_modelState"}, "client.dll")
local m_iHealth = GetOffset({"client.dll", "classes", "C_BaseEntity", "fields", "m_iHealth"}, "client.dll")
 
ReserveMenuElement(9) 
 
CheckBox("Head ESP", false) --Head ESP
CheckBox("Bone ESP", false) --Bone ESP
 
ColorPicker("- Low HP Color", Color(247, 27, 7, 255)) --Head and Bone ESP
ColorPicker("- High HP Color", Color(68, 247, 2, 255)) --Head and Bone ESP
 
CheckBox("Skip Team", true) --Head and Bone ESP
CheckBox("Visualize Distance", false) --Head and Bone ESP
 
SliderFloat("Bone Thickness", 0.1, 50.0, 2.0) --Bone ESP
 
SliderFloat("Max Distance", 1.0, 10000.0, 10000.0) --Head and Bone ESP
ColorPicker("Distance circle color", Color(255, 255, 255, 255)) --Head and Bone ESP
 
Clear()
 
Print("Head ESP Loaded")
Print("Bone ESP Loaded")
 
local function AdjustRadiusByDistance(distance)
    local base_radius = 325
    local adjusted_radius = base_radius / (1 + 0.1 * distance)
    if distance < 50 then
        adjusted_radius = adjusted_radius * (1 + (50 - distance) / 500)
    end
 
    return adjusted_radius
end
 
local function ColorCalc(clr1,clr2,t)
    local r = math.floor(clr1[1] + (clr2[1] - clr1[1]) * t)
        
    local g = math.floor(clr1[2] + (clr2[2] - clr1[2]) * t)
 
    local b = math.floor(clr1[3] + (clr2[3] - clr1[3]) * t)
    
    local a = math.floor(clr1[4] + (clr2[4] - clr1[4]) * t)
    return Color(r,g,b,a)
end
 
local function HeadESP()
    local maxDistance = GetSliderFloat("Max Distance")
 
    local localInfo = GetLocalInfo()
    local entity_list = GetEntities()
    
    if not entity_list or #entity_list == 0 then
        return
    end
    
    local localPlayer = localInfo[1]
    local localGameSceneNode = ReadPointer(localPlayer + m_pGameSceneNode)
    local localAbsOrigin = ReadVector3D(localGameSceneNode + m_vecAbsOrigin)
 
    for i = 1, #entity_list do
        if not GetCheckBox("Head ESP") then
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
 
        local Health = ReadInt(playerPawn + m_iHealth)
        if Health == 0 then
            goto continue
        end
 
       
        local distance = math.sqrt(
            (localAbsOrigin[1] - vecAbsOrigin[1])^2 +
            (localAbsOrigin[2] - vecAbsOrigin[2])^2 +
            (localAbsOrigin[3] - vecAbsOrigin[3])^2
        )
        if GetCheckBox("Visualize Distance") then
            Circle3D(localAbsOrigin, maxDistance, 1.0, GetColorPicker("Distance circle color"))
        end
 
        if distance > maxDistance then
            goto continue
        end
        local color=ColorCalc(GetColorPicker("- Low HP Color"),GetColorPicker("- High HP Color"),Health/100)
        
        if not GetCheckBox("Head ESP") then
            goto continue
        end
 
        local boneArray = ReadPointer(GameSceneNode + m_modelState + 0x80)
        local bonePos = ReadVector3D(boneArray + 6 * 32)
        local ScreenPos = WorldToScreen(bonePos)
        local radiusByDistance = AdjustRadiusByDistance(distance)
 
        if not GetCheckBox("Skip Team") then
                Circle2D(Vector2D(ScreenPos[1], ScreenPos[2]), radiusByDistance, color, 15, 2.0)
        else
            if localInfo[4] == entity[4] then
                    goto continue
            else
                Circle2D(Vector2D(ScreenPos[1], ScreenPos[2]), radiusByDistance, color, 15, 2.0)
            end
 
        end
        ::continue::
    end
end
 
local BONE_CONNECTIONS = {
    {0, 2},
    {2, 4},
    {4, 5},
    {5, 6},
    {4, 8},
    {8, 9},
    {9, 10},
    {4, 13},
    {13, 14},
    {14, 15},
    {0, 22},
    {22, 23},
    {23, 24},
    {0, 25},
    {25, 26},
    {26, 27}
}
 
local function BoneESP()
    local maxDistance = GetSliderFloat("Max Distance")
 
    local localInfo = GetLocalInfo()
    local entity_list = GetEntities()
    
    if not entity_list or #entity_list == 0 then
        return
    end
    
    local localPlayer = localInfo[1]
    local localGameSceneNode = ReadPointer(localPlayer + m_pGameSceneNode)
    local localAbsOrigin = ReadVector3D(localGameSceneNode + m_vecAbsOrigin)
 
    for i = 1, #entity_list do
        if not GetCheckBox("Bone ESP") then
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
 
        local Health = ReadInt(playerPawn + m_iHealth)
        if Health == 0 then
            goto continue
        end
 
       
        local distance = math.sqrt(
            (localAbsOrigin[1] - vecAbsOrigin[1])^2 +
            (localAbsOrigin[2] - vecAbsOrigin[2])^2 +
            (localAbsOrigin[3] - vecAbsOrigin[3])^2
        )
        if GetCheckBox("Visualize Distance") then
            Circle3D(localAbsOrigin, maxDistance, 1.0, GetColorPicker("Distance circle color"))
        end
 
        if distance > maxDistance then
            goto continue
        end
        local color=ColorCalc(GetColorPicker("- Low HP Color"),GetColorPicker("- High HP Color"),Health/100)
        
 
        local boneArray = ReadPointer(GameSceneNode + m_modelState + 0x80)
        local bonePos = ReadVector3D(boneArray + 6 * 32)
        local ScreenPos = WorldToScreen(bonePos)
        for _, connection in ipairs(BONE_CONNECTIONS) do
            local bone1 = ReadVector3D(boneArray + connection[1] * 32)
            local bone2 = ReadVector3D(boneArray + connection[2] * 32)
            local screenPos1 = WorldToScreen(bone1)
            local screenPos2 = WorldToScreen(bone2)
 
            if (screenPos1[1] == 0 and screenPos1[2] == 0) or (screenPos2[1] == 0 and screenPos2[2] == 0) then
                goto continue_bones
            end
            
            if not GetCheckBox("Skip Team") then
                Line(screenPos1, screenPos2, color, GetSliderFloat("Bone Thickness"))
            else
                if localInfo[4] == entity[4] then
                    goto continue_bones
                else
                    Line(screenPos1, screenPos2, color, GetSliderFloat("Bone Thickness"))
                end
 
            end
           
            ::continue_bones::
        end
        
        ::continue::
    end
end
 
RegisterCallback(BoneESP)
RegisterCallback(HeadESP)
