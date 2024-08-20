ocal ClientDLL = GetClientDLL()
 
local Offsets = {
	m_pGameSceneNode = GetOffset({ "client.dll", "classes", "C_BaseEntity", "fields", "m_pGameSceneNode" }, "client.dll"),
	m_vecAbsOrigin = GetOffset({ "client.dll", "classes", "CGameSceneNode", "fields", "m_vecAbsOrigin" }, "client.dll"),
	dwEntityList = GetOffset({ "client.dll", "dwEntityList" }, "offsets"),
	m_pEntity = GetOffset({ "client.dll", "classes", "CEntityInstance", "fields", "m_pEntity" }, "client.dll"),
	m_designerName = GetOffset({ "client.dll", "classes", "CEntityIdentity", "fields", "m_designerName" }, "client.dll"),
	m_iState = GetOffset({ "client.dll", "classes", "C_CSWeaponBase", "fields", "m_iState" }, "client.dll"),
}
 
local ScreenCenter = Vector2D(math.floor(GetScreenSize()[1] / 2), math.floor(GetScreenSize()[2] / 2))
local Grenades = {}
 
ReserveMenuElement(18)
CreateText("\n")
CreateText("ESP")
CheckBox("Line ESP", false)
CheckBox("Circle", false)
CheckBox("Icon", false)
CheckBox("Name", false)
CreateText("\n")
CreateText("Colors")
ColorPicker("Line color", Color(255, 255, 255, 255))
ColorPicker("Circle color", Color(255, 255, 255, 255))
ColorPicker("Icon color", Color(255, 255, 255, 255))
ColorPicker("Name color", Color(255, 255, 255, 255))
CreateText("\n")
CreateText("Misc")
SliderFloat("Max Distance", 1.0, 10000.0, 10000.0)
SliderFloat("Circle radius", 1.0, 40.0, 5.0)
SliderFloat("Line Stickness", 0.1, 10.0, 1.0)
CreateText("\n")
 
local GrenadeTypes = {
	["weapon_smokegrenade"] = { "Smoke", "smoke_icon" },
	["smokegrenade_projectile"] = { "Smoke", "smoke_icon" },
	["weapon_flashbang"] = { "Flash", "flash_icon" },
	["flashbang_projectile"] = { "Flash", "flash_icon" },
	["weapon_hegrenade"] = { "HE", "he_icon" },
	["hegrenade_projectile"] = { "HE", "he_icon" },
	["weapon_molotov"] = { "Molotov", "molotov_icon" },
	["molotov_projectile"] = { "Molotov", "molotov_icon" },
	["weapon_incgrenade"] = { "Incendiary", "incendiary_icon" },
	["incgrenade_projectile"] = { "Incendiary", "incendiary_icon" },
	["weapon_decoy"] = { "Decoy", "decoy_icon" },
	["decoy_projectile"] = { "Decoy", "decoy_icon" }
}
 
local function FindEntities()
	local EntityList = ReadPointer(ClientDLL + Offsets.dwEntityList)
 
	if EntityList == 0 then
		return
	end 
 
	for i = 1, 1024 do
		local ListEntry = ReadPointer(EntityList + 8 * ((i & 0x7FFF) >> 9) + 16)
		
		if ListEntry == 0 then
			goto continue
		end
 
		local BaseEntity = ReadPointer(ListEntry + 120 * (i & 0x1FF))
 
		if BaseEntity == 0 then
			goto continue
		end
 
		local pEntity = ReadPointer(BaseEntity + Offsets.m_pEntity)
 
		if pEntity == 0 then
			goto continue
		end
 
		local designerName = ReadPointer(pEntity + Offsets.m_designerName)
 
		if designerName == 0 then
			goto continue
		end
 
		local grenadeType = GrenadeTypes[tostring(ReadString(designerName))]
 
		if grenadeType == nil then
			goto continue
		end
 
		local m_iStateValue = ReadInt(BaseEntity + Offsets.m_iState)
 
		if m_iStateValue == 1 or m_iStateValue == 2 then
			goto continue
		end 
 
		table.insert(Grenades, { BaseEntity, grenadeType })
 
		::continue::
	end
end 
 
local function DrawGrenades()
	Grenades = {}
 
	FindEntities()
 
	local localAbsOrigin = ReadVector3D(ReadPointer(GetLocalInfo()[1] + Offsets.m_pGameSceneNode) + Offsets.m_vecAbsOrigin)
 
	for i, grenadeData in ipairs(Grenades) do
		local GameSceneNode = ReadPointer(grenadeData[1] + Offsets.m_pGameSceneNode)
 
		if GameSceneNode == 0 then
			goto continue
		end
 
		local vecAbsOrigin = ReadVector3D(GameSceneNode + Offsets.m_vecAbsOrigin)
 
		if math.sqrt((localAbsOrigin[1] - vecAbsOrigin[1]) ^ 2 + (localAbsOrigin[2] - vecAbsOrigin[2]) ^ 2 + (localAbsOrigin[3] - vecAbsOrigin[3]) ^ 2) > GetSliderFloat("Max Distance") then
			goto continue
		end
 
		local smokePos = Vector3D(vecAbsOrigin[1], vecAbsOrigin[2], vecAbsOrigin[3])
		local ScreenPos = WorldToScreen(smokePos)
 
		if ScreenPos[1] == 0 and ScreenPos[2] == 0 then
			goto continue
		end
 
		if GetCheckBox("Line ESP") then
			Line(ScreenPos, Vector2D(ScreenCenter[1], ScreenCenter[2]), GetColorPicker("Line color"), GetSliderFloat("Line Stickness"))
		end
 
		if GetCheckBox("Circle") then
			Circle3D(smokePos, GetSliderFloat("Circle radius"), 2.0, GetColorPicker("Circle color"))
		end
 
		if GetCheckBox("Name") then
			local ScreenTextPos = WorldToScreen(Vector3D(vecAbsOrigin[1], vecAbsOrigin[2], math.floor(vecAbsOrigin[3] - 10)))
 
			if ScreenTextPos[1] == 0 and ScreenTextPos[2] == 0 then
				goto continue
			end
 
			Text(grenadeData[2][1], ScreenTextPos, GetColorPicker("Name color"), false)
		end 
 
		if GetCheckBox("Icon") then
			local ScreenIconPos = WorldToScreen(Vector3D(vecAbsOrigin[1], vecAbsOrigin[2], math.floor(vecAbsOrigin[3] + 10)))
 
			if ScreenIconPos[1] == 0 and ScreenIconPos[2] == 0 then
				goto continue
			end
 
			Text(grenadeData[2][2], ScreenIconPos, GetColorPicker("Icon color"), false)
		end
 
		::continue::
	end
end 
RegisterCallback(DrawGrenades)
