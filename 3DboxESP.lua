local m_pGameSceneNode = GetOffset({"client.dll", "classes", "C_BaseEntity", "fields", "m_pGameSceneNode"}, "client.dll")
local m_vecAbsOrigin = GetOffset({"client.dll", "classes", "CGameSceneNode", "fields", "m_vecAbsOrigin"}, "client.dll")
local m_modelState = GetOffset({"client.dll", "classes", "CSkeletonInstance", "fields", "m_modelState"}, "client.dll")
local m_iHealth = GetOffset({"client.dll", "classes", "C_BaseEntity", "fields", "m_iHealth"}, "client.dll")
 
ReserveMenuElement(4) 
CheckBox("3D Box ESP", false) 
CheckBox("Skip Team", false) 
ColorPicker("Enemy color", Color(255, 255, 255, 255))
ColorPicker("Team color", Color(255, 255, 255, 255))
 
Clear()
Print("3D Box ESP Loaded") 
 
local function Draw3DBoxESP()
    local teamColor = GetColorPicker("Team color")
    local enemyColor = GetColorPicker("Enemy color")
 
    local localInfo = GetLocalInfo()
    local entityList = GetEntities() 
 
    if not entityList or #entityList == 0 then
        return
    end
 
    for i = 1, #entityList do
        if not GetCheckBox("3D Box ESP") then
            goto continue
        end
 
        local entity = entityList[i]
        if not entity or #entity < 1 then
            goto continue
        end
 
        local playerPawn = entity[1]
        if not playerPawn or playerPawn == 0 then
            goto continue
        end
 
        local gameSceneNode = ReadPointer(playerPawn + m_pGameSceneNode)
        if not gameSceneNode or gameSceneNode == 0 then
            goto continue
        end
 
        local vecAbsOrigin = ReadVector3D(gameSceneNode + m_vecAbsOrigin)
        if vecAbsOrigin[1] == 0 and vecAbsOrigin[2] == 0 and vecAbsOrigin[3] == 0 then
            goto continue
        end
 
        local boneArray = ReadPointer(gameSceneNode + m_modelState + 0x80)
        local head = ReadVector3D(boneArray + 6 * 32)
 
        local health = ReadInt(playerPawn + m_iHealth)
        if health > 0 then
            
            local function DrawBox(origin, head, color, widthFactor)
                local width = 30.0
                local halfWidth = width / 2.0
                local height = math.floor(head[3] - origin[3] + 10)
 
                local corners = {
                    Vector3D(origin[1] + halfWidth, origin[2] + halfWidth, origin[3]), -- Bottom-front-right corner
                    Vector3D(origin[1] + halfWidth, origin[2] - halfWidth, origin[3]), -- Bottom-back-right corner
                    Vector3D(origin[1] - halfWidth, origin[2] - halfWidth, origin[3]), -- Bottom-back-left corner
                    Vector3D(origin[1] - halfWidth, origin[2] + halfWidth, origin[3]), -- Bottom-front-left corner
                    Vector3D(origin[1] + halfWidth, origin[2] + halfWidth, origin[3] + height), -- Top-front-right corner
                    Vector3D(origin[1] + halfWidth, origin[2] - halfWidth, origin[3] + height), -- Top-back-right corner
                    Vector3D(origin[1] - halfWidth, origin[2] - halfWidth, origin[3] + height), -- Top-back-left corner
                    Vector3D(origin[1] - halfWidth, origin[2] + halfWidth, origin[3] + height) -- Top-front-left corner
                }
                
                local screenCorners = {}
                for i = 1, 8 do
                    screenCorners[i] = WorldToScreen(Vector3D(math.floor(corners[i][1]), math.floor(corners[i][2]), math.floor(corners[i][3])))
                end
                
                local function IsValidPoint(pt)
                    return pt[1] ~= 0 or pt[2] ~= 0
                end
                
                if IsValidPoint(screenCorners[1]) and IsValidPoint(screenCorners[2]) then
                    Line(screenCorners[1], screenCorners[2], color, 2.0)
                end
 
                if IsValidPoint(screenCorners[2]) and IsValidPoint(screenCorners[3]) then
                    Line(screenCorners[2], screenCorners[3], color, 2.0)
                end
 
                if IsValidPoint(screenCorners[3]) and IsValidPoint(screenCorners[4]) then
                    Line(screenCorners[3], screenCorners[4], color, 2.0)
                end
 
                if IsValidPoint(screenCorners[4]) and IsValidPoint(screenCorners[1]) then
                    Line(screenCorners[4], screenCorners[1], color, 2.0)
                end
 
                if IsValidPoint(screenCorners[5]) and IsValidPoint(screenCorners[6]) then
                    Line(screenCorners[5], screenCorners[6], color, 2.0)
                end
 
                if IsValidPoint(screenCorners[6]) and IsValidPoint(screenCorners[7]) then
                    Line(screenCorners[6], screenCorners[7], color, 2.0)
                end
 
                if IsValidPoint(screenCorners[7]) and IsValidPoint(screenCorners[8]) then
                    Line(screenCorners[7], screenCorners[8], color, 2.0)
                end
                
                if IsValidPoint(screenCorners[8]) and IsValidPoint(screenCorners[5]) then
                    Line(screenCorners[8], screenCorners[5], color, 2.0)
                end
                
                
                for i = 1, 4 do
                    if IsValidPoint(screenCorners[i]) and IsValidPoint(screenCorners[i+4]) then
                        Line(screenCorners[i], screenCorners[i+4], color, 2.0)
                    end
                end
            end
            
            
            
            if localInfo[4] == entity[4] and not GetCheckBox("Skip Team") then
                DrawBox(vecAbsOrigin, head, teamColor, widthFactor)
            elseif localInfo[4] ~= entity[4] then
                DrawBox(vecAbsOrigin, head, enemyColor, widthFactor)
            end
        end
 
        ::continue::
    end
end
 
RegisterCallback(Draw3DBoxESP)
