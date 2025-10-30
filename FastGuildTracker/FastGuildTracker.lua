local ADDON_NAME = ...
local ADDON_DB   = "FastGuildTrackerDB"
local L          = _G.FastGuildTrackerLocale or { title="FastGuildTracker" }

-- ============================================================================
-- Config
local TABLE_COLUMN_NUM   = 4
local TABLE_COLUMN_WIDTH = 150
local ROW_HEIGHT         = 24
local FADE_WHILE_MOVING  = true
local ONLY_ONLINE        = true
local NAME_ICON_PAD      = 34
local ICON_SIZE          = 14

-- SavedVariables defaults
local function EnsureDefaults()
  _G[ADDON_DB] = _G[ADDON_DB] or {}
  local db = _G[ADDON_DB]
  db.minimap      = db.minimap or { hide = false }
  if db.showMinimap == nil then db.showMinimap = true end
  if db.onlyOnline  == nil then db.onlyOnline  = true end
  db.debug        = db.debug or false
  db.minimapNudge = db.minimapNudge or { x = 0, y = 0 }
  db.raceCache    = db.raceCache or {}
  return db
end

-- Addon table
local FGT = CreateFrame("Frame"); _G.FastGuildTracker = FGT
FGT:SetScript("OnEvent", function(self, event, ...) if self[event] then self[event](self, ...) end end)

-- Debug helpers
function FGT:IsDebug() return EnsureDefaults().debug and true or false end
function FGT:DebugEnable(enabled)
  local db = EnsureDefaults()
  db.debug = not not enabled
  print("|cff33ff99FGT:|r "..(db.debug and (L.debug_on or "Debug logging |cff44ff44enabled|r.") or (L.debug_off or "Debug logging |cffff4444disabled|r.")))
end
local function debugPrint(...) if FGT:IsDebug() then print("|cff33ff99FGT:|r", ...) end end

local CreateWindow, Populate
local mainFrame
local isReloading = false

-- Public API for options
function FGT:GetDB() return EnsureDefaults() end
function FGT:SetOnlyOnline(enabled)
  local db = EnsureDefaults()
  db.onlyOnline = not not enabled
  ONLY_ONLINE   = db.onlyOnline
  if mainFrame then Populate(mainFrame) end
end
function FGT:SetMinimapShown(enabled)
  local db   = EnsureDefaults()
  local show = not not enabled
  db.showMinimap  = show
  db.minimap.hide = not show
  if self.ldbIcon and self.ldbIcon:IsRegistered("FastGuildTracker") then
    if show then self.ldbIcon:Show("FastGuildTracker") else self.ldbIcon:Hide("FastGuildTracker") end
    if L.minimap_on then print("|cff33ff99FGT:|r "..(show and L.minimap_on or L.minimap_off)) end
  end
end
function FGT:SetMinimapIcon(icon)
  if not self.ldbIcon or not self.ldbIcon:IsRegistered("FastGuildTracker") then return end
  self.ldbIcon:SetIcon("FastGuildTracker", icon)
end
function FGT:SetMinimapIconNudge(x, y)
  local db = EnsureDefaults()
  db.minimapNudge.x, db.minimapNudge.y = x or 0, y or 0
  if self.ldbIcon and self.ldbIcon.GetMinimapButton then
    local btn = self.ldbIcon:GetMinimapButton("FastGuildTracker")
    if btn and btn.icon then
      btn.icon:ClearAllPoints()
      btn.icon:SetPoint("CENTER", btn, "CENTER", db.minimapNudge.x or 0, db.minimapNudge.y or 0)
    end
  end
end

-- UI helpers
local function OnUpdate(self)
  if not FADE_WHILE_MOVING then return end
  self:SetAlpha((IsPlayerMoving() and not self:IsMouseOver()) and 0.5 or 1.0)
end

-- ============================================================================
-- Region-Autoerkennung + DB-Module je Region
local function FGT_GetRegionTag()
  if GetCurrentRegionName then
    local r = GetCurrentRegionName()
    if r == 1 then return "US" elseif r == 2 then return "KR" elseif r == 3 then return "EU" elseif r == 4 then return "TW" end
  end
  local p = GetCVar and (GetCVar("portal") or "") or ""
  p = p:lower()
  if p:find("eu") then return "EU" elseif p:find("us") or p:find("oce") then return "US"
  elseif p:find("kr") then return "KR" elseif p:find("tw") then return "TW" end
  return "EU"
end

local function FGT_RegionModules(tag)
  tag = tag or FGT_GetRegionTag()
  return {
    ("RaiderIO_DB_%s_M"):format(tag),
    ("RaiderIO_DB_%s_R"):format(tag),
    ("RaiderIO_DB_%s_F"):format(tag),
  }, tag
end

-- Locale keys: prefer db_* and fall back to eu_* for compatibility
local function L_KEY(k, fallbackEU)
  return L[k] or (fallbackEU and L["eu_"..fallbackEU]) or nil
end

function FGT:CheckRegionDBLoaded()
  local mods, tag = FGT_RegionModules()
  local missing = {}
  for _, a in ipairs(mods) do
    if not (C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(a)) then
      table.insert(missing, a)
    end
  end
  return (#missing == 0), missing, tag
end

function FGT:EnsureRegionDBLoaded()
  local mods, tag = FGT_RegionModules()
  if not (C_AddOns and C_AddOns.EnableAddOn and C_AddOns.LoadAddOn) then
    print("|cffff5555FGT:|r "..(L_KEY("db_load_failed","load_failed") or "DB load failed").." (API)")
    return false
  end
  for _, a in ipairs(mods) do
    C_AddOns.EnableAddOn(a)
    pcall(C_AddOns.LoadAddOn, a)
  end
  local all, missing = self:CheckRegionDBLoaded()
  if all then
    print("|cff33ff99FGT:|r "..(L_KEY("db_loaded","loaded") or "Database loaded.").." ("..FGT_GetRegionTag()..")")
  else
    print("|cffff5555FGT:|r "..(L_KEY("db_load_failed","load_failed") or "DB load failed")..": "..table.concat(missing, ", "))
  end
  return all
end

function FGT:WarnIfNoRegionDB()
  local ok, missing, tag = self:CheckRegionDBLoaded()
  if not ok then
    local msg = L_KEY("db_warn_chat","warn_chat") or "Raider.IO DB not loaded. Scores may be missing. Open options or type /fgt loaddb."
    print("|cffff5555FGT:|r ["..tag.."] "..msg)
  end
end

-- ============================================================================
-- Modernes Fenster
local function CreateModernContainer()
  local f = CreateFrame("Frame", "FastGuildTrackerFrame", UIParent, "BackdropTemplate")
  f:SetSize(680, 400)
  f:SetPoint("CENTER")
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p, r, rp, x, y = self:GetPoint()
    local db = EnsureDefaults()
    db.position = { p, r, rp, x, y }
  end)
  f:SetScript("OnMouseDown", function(self) self:SetToplevel(true) end)
  f:SetScript("OnUpdate", OnUpdate)
  f:SetClampedToScreen(true)
  f:SetFrameStrata("MEDIUM")
  f:Hide()

  local bg = f:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetColorTexture(0.08, 0.09, 0.10, 0.95)
  local border = CreateFrame("Frame", nil, f, "BackdropTemplate")
  border:SetPoint("TOPLEFT", 1, -1); border:SetPoint("BOTTOMRIGHT", -1, 1)
  border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 }); border:SetBackdropBorderColor(0,0,0,1)
  local shadow = f:CreateTexture(nil, "BACKGROUND", nil, -1)
  shadow:SetPoint("TOPLEFT", -6, 6); shadow:SetPoint("BOTTOMRIGHT", 6, -6)
  shadow:SetTexture("Interface\\Buttons\\WHITE8x8"); shadow:SetVertexColor(0,0,0,0.35)

  local bar = f:CreateTexture(nil, "ARTWORK"); bar:SetPoint("TOPLEFT", 0, 0); bar:SetPoint("TOPRIGHT", 0, 0); bar:SetHeight(36); bar:SetColorTexture(0.12,0.14,0.18,1)
  local underline = f:CreateTexture(nil, "ARTWORK"); underline:SetPoint("TOPLEFT",0,-36); underline:SetPoint("TOPRIGHT",0,-36); underline:SetHeight(1); underline:SetColorTexture(0,0,0,1)

  local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", f, "TOP", 0, -9)
  title:SetText(L.title or "FastGuildTracker")
  title:SetJustifyH("CENTER"); title:SetTextColor(1,1,1,1); title:SetShadowColor(0,0,0,1); title:SetShadowOffset(1,-1)
  f.TitleText = title

  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton"); close:SetPoint("TOPRIGHT", 2, 2); close:SetScale(0.9)

  local header = CreateFrame("Frame", nil, f); header:SetPoint("TOPLEFT", 12, -44); header:SetPoint("TOPRIGHT", -12, -44); header:SetHeight(26)
  local headerBg = header:CreateTexture(nil, "ARTWORK"); headerBg:SetAllPoints(); headerBg:SetColorTexture(0.16,0.18,0.22,1)
  local headerLine = header:CreateTexture(nil, "ARTWORK"); headerLine:SetPoint("BOTTOMLEFT"); headerLine:SetPoint("BOTTOMRIGHT"); headerLine:SetHeight(1); headerLine:SetColorTexture(0,0,0,1)

  local scrollFrame = CreateFrame("ScrollFrame", "FastGuildTrackerScroll", f, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", 12, -72); scrollFrame:SetPoint("BOTTOMRIGHT", -28, 12)
  local content = CreateFrame("Frame", nil, scrollFrame); scrollFrame:SetScrollChild(content)
  content:SetSize(900, 800); content.rows = {}; f.content = content

  local function CreateHeaderText(parent, x, text)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("LEFT", parent, "LEFT", x, 0); fs:SetWidth(TABLE_COLUMN_WIDTH); fs:SetJustifyH("LEFT")
    fs:SetText(text); fs:SetTextColor(1,1,1,0.95); fs:SetShadowColor(0,0,0,1); fs:SetShadowOffset(1,-1)
    return fs
  end

  f.header = header
  f.h1 = CreateHeaderText(header, 0,                      L.name_col   or "Name")
  f.h2 = CreateHeaderText(header, 1 * TABLE_COLUMN_WIDTH, L.runs_col   or "M+ Runs")
  f.h3 = CreateHeaderText(header, 2 * TABLE_COLUMN_WIDTH, L.rating_col or "M+ Rating")
  f.h4 = CreateHeaderText(header, 3 * TABLE_COLUMN_WIDTH, L.best_col   or "Best Raid Kill")

  local db = EnsureDefaults(); if db.position then f:ClearAllPoints(); f:SetPoint(unpack(db.position)) end
  return f
end

CreateWindow = function()
  local frame = CreateModernContainer()

  local function ensureRow(idx)
    if frame.content.rows[idx] then return frame.content.rows[idx] end
    local row = CreateFrame("Frame", nil, frame.content)
    row:SetSize(TABLE_COLUMN_WIDTH * TABLE_COLUMN_NUM, ROW_HEIGHT)
    row:SetPoint("TOPLEFT", 12, -((idx-1) * ROW_HEIGHT))
    if (idx % 2 == 0) then local z = row:CreateTexture(nil, "BACKGROUND"); z:SetAllPoints(); z:SetColorTexture(1,1,1,0.02); row.zebra = z end

    row.raceIcon  = row:CreateTexture(nil, "ARTWORK")
    row.classIcon = row:CreateTexture(nil, "ARTWORK")
    row.raceIcon:SetSize(ICON_SIZE, ICON_SIZE); row.classIcon:SetSize(ICON_SIZE, ICON_SIZE)
    row.raceIcon:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.classIcon:SetPoint("LEFT", row.raceIcon, "RIGHT", 4, 0)

    row.cols = {}
    for j = 1, TABLE_COLUMN_NUM do
      local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      local xOffset = (j == 1) and (NAME_ICON_PAD) or ((j-1)*TABLE_COLUMN_WIDTH)
      fs:SetPoint("LEFT", xOffset, 0)
      fs:SetWidth(TABLE_COLUMN_WIDTH - ((j == 1) and NAME_ICON_PAD or 0))
      fs:SetJustifyH("LEFT"); fs:SetTextColor(0.9,0.9,0.9,1)
      fs:SetShadowColor(0,0,0,1); fs:SetShadowOffset(1,-1)
      row.cols[j] = fs
    end

    row.nameBtn = CreateFrame("Button", nil, row)
    row.nameBtn:SetPoint("LEFT", 0, 0); row.nameBtn:SetSize(TABLE_COLUMN_WIDTH, ROW_HEIGHT)
    row.nameBtn:SetScript("OnEnter", function(self)
      local e = row._entry; if not e then return end
      FGT:ShowMemberTooltip(self, e.name or "?", e.rioProfile)
    end)
    row.nameBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    frame.content.rows[idx] = row
    return row
  end

  frame.ensureRow = ensureRow
  return frame
end

function FGT:Toggle()
  if not mainFrame then mainFrame = CreateWindow() end
  if mainFrame:IsShown() then HideUIPanel(mainFrame) else ShowUIPanel(mainFrame) end
end

-- === ROBUSTE RAIDERIO-PROFIL-SUCHE (ersetzt deine bisherige GetRIOProfile) ===
local function GetRIOProfile(fullName)
  if not RaiderIO then
    debugPrint(L.debug_no_rio or "[DEBUG] RaiderIO not loaded")
    return nil
  end
  if not fullName or fullName == "" then
    debugPrint(L.debug_profile_nil_name or "[DEBUG] fullName is empty")
    return nil
  end

  -- Name & Realm separieren und verschiedene Schreibweisen vorbereiten
  local name, realm = fullName:match("^(.-)%-(.+)$")
  if not name then
    -- falls aus irgendeinem Grund ohne Realm reinkommt, Realm des Spielers versuchen
    local rn = GetNormalizedRealmName() or GetRealmName() or ""
    if rn ~= "" then
      fullName = fullName .. "-" .. rn
      name, realm = fullName:match("^(.-)%-(.+)$")
    end
  end
  if realm then
    -- „Realm Slug“ ermitteln (z. B. "Malfurion" -> "malfurion"), wenn RIO das anbietet
    local realmSlug
    if type(RaiderIO.GetRealmSlug) == "function" then
      local ok, slug = pcall(RaiderIO.GetRealmSlug, realm)
      if ok and type(slug) == "string" and slug ~= "" then
        realmSlug = slug
      end
    end

    -- 1) Versuch: alter Stil mit "Name-Realm"
    if type(RaiderIO.GetProfile) == "function" then
      local ok, prof = pcall(RaiderIO.GetProfile, fullName)
      if ok and type(prof) == "table" then
        debugPrint((L.debug_profile_ok or "[DEBUG] Profile OK:"), fullName, "(single arg)")
        return prof
      end
    end
    if type(RaiderIO.GetProfile) == "function" and type(RaiderIO.GetProfile) ~= "userdata" then
      -- 2) Versuch: getrennt name, realm
      local ok2, prof2 = pcall(RaiderIO.GetProfile, name, realm)
      if ok2 and type(prof2) == "table" then
        debugPrint((L.debug_profile_ok or "[DEBUG] Profile OK:"), name, realm, "(name, realm)")
        return prof2
      end
      -- 3) Versuch: name, realmSlug
      if realmSlug then
        local ok3, prof3 = pcall(RaiderIO.GetProfile, name, realmSlug)
        if ok3 and type(prof3) == "table" then
          debugPrint((L.debug_profile_ok or "[DEBUG] Profile OK:"), name, realmSlug, "(name, realmSlug)")
          return prof3
        end
      end
    end

    -- Manche RIO-Versionen exponieren Methoden als :Method(...) statt .Function(...)
    if type(RaiderIO.GetProfile) ~= "function" and type(RaiderIO) == "table" and RaiderIO.GetProfile then
      -- 4) Versuch: method call
      local ok4, prof4 = pcall(RaiderIO.GetProfile, RaiderIO, fullName)
      if ok4 and type(prof4) == "table" then
        debugPrint((L.debug_profile_ok or "[DEBUG] Profile OK:"), fullName, "(method, single arg)")
        return prof4
      end
      local ok5, prof5 = pcall(RaiderIO.GetProfile, RaiderIO, name, realm)
      if ok5 and type(prof5) == "table" then
        debugPrint((L.debug_profile_ok or "[DEBUG] Profile OK:"), name, realm, "(method, name, realm)")
        return prof5
      end
      if realmSlug then
        local ok6, prof6 = pcall(RaiderIO.GetProfile, RaiderIO, name, realmSlug)
        if ok6 and type(prof6) == "table" then
          debugPrint((L.debug_profile_ok or "[DEBUG] Profile OK:"), name, realmSlug, "(method, name, realmSlug)")
          return prof6
        end
      end
    end
  else
    -- kein Realm in fullName gefunden → best effort Ein-Argument-Variante
    if type(RaiderIO.GetProfile) == "function" then
      local ok, prof = pcall(RaiderIO.GetProfile, fullName)
      if ok and type(prof) == "table" then
        debugPrint((L.debug_profile_ok or "[DEBUG] Profile OK:"), fullName, "(no realm in name)")
        return prof
      end
    end
  end

  debugPrint((L.debug_profile_missing or "[DEBUG] Profile missing for:"), fullName)
  return nil
end

local function GetRIOForUnit(profile)
  if not profile then return nil end
  local raidProgress, raidDifficulty = "N/A", nil
  if profile.raidProfile and profile.raidProfile.progress and profile.raidProfile.progress[1] then
    raidDifficulty = profile.raidProfile.progress[1].difficulty
    raidProgress   = profile.raidProfile.progress[1].progressCount
  end
  if raidDifficulty == 1 then raidDifficulty = "Normal"
  elseif raidDifficulty == 2 then raidDifficulty = "Heroic"
  elseif raidDifficulty == 3 then raidDifficulty = "Mythic" end
  if raidProgress ~= "N/A" and raidDifficulty then raidDifficulty = " ["..raidDifficulty.."]" else raidDifficulty = "" end

  local runs, score = 0, "N/A"
  local mkp = profile.mythicKeystoneProfile
  if type(mkp) == "table" then
    for lvl=1,30 do local v = mkp["keystoneMilestone"..lvl]; if type(v)=="number" then runs = runs + v end end
    score = mkp.currentScore or mkp.mainCurrentScore or mkp.previousScore or "N/A"
  end
  return { runs = runs, mplusScore = score, raid = raidProgress, raidDifficulty = raidDifficulty }
end

-- Map index helpers (unchanged)
local FGT_MapIndex = nil
local function FGT_StripKeystoneDecorations(s) if not s or s=="" then return s end s=s:gsub("%b()",""); s=s:gsub("%+%d+",""); s=s:gsub("mythic keystone",""); s=s:gsub("mythic%+?",""); s=s:gsub("%s+"," "); s=s:match("^%s*(.-)%s*$"); return s end
local function FGT_NormalizeName(s) if not s then return nil end s=FGT_StripKeystoneDecorations(s); s=s:lower(); s=s:gsub("[^%w]",""); return s end
local function FGT_BuildMapIndex() FGT_MapIndex={byId={},byNorm={}}; if not C_ChallengeMode or not C_ChallengeMode.GetMapTable then return FGT_MapIndex end
  local ids=C_ChallengeMode.GetMapTable(); if type(ids)~="table" then return FGT_MapIndex end
  for _,id in ipairs(ids) do local name=C_ChallengeMode.GetMapUIInfo and C_ChallengeMode.GetMapUIInfo(id) or nil
    if name and name~="" then local norm=FGT_NormalizeName(name); FGT_MapIndex.byId[id]=name; if norm and norm~="" then FGT_MapIndex.byNorm[norm]=id end end
  end; return FGT_MapIndex end
local function FGT_EnsureMapIndex() if not FGT_MapIndex or (FGT_MapIndex and (not next(FGT_MapIndex.byId))) then FGT_BuildMapIndex() end return FGT_MapIndex end
local FGT_EnglishAliases = {}

local function LocalizedDungeonNameFromRun(run)
  if type(run) ~= "table" then return nil end
  FGT_EnsureMapIndex()
  local cmId = run.mapId or run.mapID or run.challengeMapID or run.challengeModeID or run.mapChallengeModeID or run.keystoneDungeonId or run.keystoneInstance or run.instanceChallengeModeID
  if type(cmId)=="number" and FGT_MapIndex and FGT_MapIndex.byId[cmId] then return FGT_MapIndex.byId[cmId] end
  local zid = run.instanceId or run.instanceID or run.zoneId or run.zoneID
  if type(zid)=="number" and C_Map and C_Map.GetMapInfo then local mi=C_Map.GetMapInfo(zid); if mi and mi.name and mi.name~="" then return mi.name end end
  local raw = run.dungeonShort or run.zoneShort or run.mapName or run.name or run.dungeon or run.map
  if type(raw)=="string" and raw~="" then
    local cleaned=FGT_StripKeystoneDecorations(raw); local norm=FGT_NormalizeName(cleaned)
    if norm and norm~="" and FGT_MapIndex then
      local aliasId=FGT_EnglishAliases[norm]; if aliasId and FGT_MapIndex.byId[aliasId] then return FGT_MapIndex.byId[aliasId] end
      local id2=FGT_MapIndex.byNorm[norm]; if id2 and FGT_MapIndex.byId[id2] then return FGT_MapIndex.byId[id2] end
      if #norm>=4 then
        for id3,locName in pairs(FGT_MapIndex.byId) do local nloc=FGT_NormalizeName(locName); if nloc and nloc:find("^"..norm) then return locName end end
        for id3,locName in pairs(FGT_MapIndex.byId) do local nloc=FGT_NormalizeName(locName); if nloc and (nloc:find(norm,1,true) or norm:find(nloc,1,true)) then return locName end end
      end
    end
    return cleaned
  end
  return nil
end

local function ExtractDungeonRunsFromProfile(profile)
  local out = {}
  if not profile or not profile.mythicKeystoneProfile then return out end
  local mkp = profile.mythicKeystoneProfile
  local function addRun(run)
    if type(run)~="table" then return end
    local level = run.level or run.keystoneLevel or run.keyLevel or run.mplusLevel or run.maxDungeonLevel
    local name  = LocalizedDungeonNameFromRun(run) or run.dungeonShort or run.zoneShort or run.mapName or run.name or run.dungeon or run.map
    if level and name then table.insert(out, { name=tostring(name), level=tonumber(level) or level }) end
  end
  local preferred = { mkp.runs, mkp.bestRuns, mkp.sortedRuns, mkp.sortedDungeons }
  for _, list in ipairs(preferred) do
    if type(list)=="table" and #list>0 then for _,r in ipairs(list) do addRun(r) end
      table.sort(out, function(a,b) return (tonumber(a.level) or 0) > (tonumber(b.level) or 0) end)
      return out
    end
  end
  if type(mkp.dungeons)=="table" then
    local had=false
    if #mkp.dungeons>0 then for _,v in ipairs(mkp.dungeons) do if type(v)=="table" then addRun(v.best or v.bestRun or v.top or v.last or v.max); had=true end end
    else for _,v in pairs(mkp.dungeons) do if type(v)=="table" then addRun(v.best or v.bestRun or v.top or v.last or v.max); had=true end end end
    if had then table.sort(out,function(a,b) return (tonumber(a.level) or 0)>(tonumber(b.level) or 0) end); return out end
  end
  local more={mkp.dungeonTimes,mkp.warbandDungeonTimes,mkp.warbandDungeons}
  for _,list in ipairs(more) do
    if type(list)=="table" then
      local found=false
      if #list>0 then for _,v in ipairs(list) do if type(v)=="table" then addRun(v); found=true end end
      else for _,v in pairs(list) do if type(v)=="table" then addRun(v); found=true end end end
      if found then table.sort(out,function(a,b) return (tonumber(a.level) or 0)>(tonumber(b.level) or 0) end); return out end
    end
  end
  if type(mkp.maxDungeon)=="table" or tonumber(mkp.maxDungeonLevel) then
    local fake={ name=(type(mkp.maxDungeon)=="table" and (mkp.maxDungeon.mapName or mkp.maxDungeon.dungeon or mkp.maxDungeon.name)) or "Best Dungeon",
                 level=tonumber(mkp.maxDungeonLevel) or (type(mkp.maxDungeon)=="table" and (mkp.maxDungeon.level or mkp.maxDungeon.keyLevel)) }
    if fake.name and fake.level then table.insert(out, { name=tostring(fake.name), level=fake.level }) end
  end
  table.sort(out,function(a,b) return (tonumber(a.level) or 0)>(tonumber(b.level) or 0) end)
  return out
end

function FGT:ShowMemberTooltip(anchorFrame, unitNameDisplay, unitProfile)
  GameTooltip:SetOwner(anchorFrame, "ANCHOR_RIGHT"); GameTooltip:ClearLines(); FGT_EnsureMapIndex()
  GameTooltip:AddLine(unitNameDisplay, 1,1,1)
  if not RaiderIO or not unitProfile then
    GameTooltip:AddLine(L.no_rio_detail or "RaiderIO data not available.", 1,0.4,0.4); debugPrint(L.debug_tooltip_no_rio or "[DEBUG] Tooltip: no RIO detail"); GameTooltip:Show(); return
  end
  local score = unitProfile.mythicKeystoneProfile and unitProfile.mythicKeystoneProfile.currentScore
  if score then GameTooltip:AddDoubleLine(L.mplus_score or "M+ Score", tostring(score), 0.8,0.8,0.8, 0,1,0.6) end
  local runs = ExtractDungeonRunsFromProfile(unitProfile)
  if #runs==0 then GameTooltip:AddLine(L.no_rio_detail or "No detailed dungeon runs from RaiderIO.", 0.9,0.75,0.75)
  else
    GameTooltip:AddLine(L.dungeons_header or "Recent / Best Dungeons:", 0.2,1,0.2)
    local maxLines=8
    for i=1, math.min(#runs,maxLines) do local r=runs[i]; GameTooltip:AddDoubleLine(("• %s"):format(r.name), ("+%s"):format(r.level), 0.9,0.9,0.9, 0.9,0.9,0.9) end
    if #runs>maxLines then GameTooltip:AddLine((L.and_more or "...and %d more"):format(#runs-maxLines), 0.7,0.7,0.7) end
  end
  GameTooltip:Show()
end

local function LocalizedClassToFileToken(localized)
  if not localized then return nil end
  for token, loc in pairs(LOCALIZED_CLASS_NAMES_MALE or {}) do if loc==localized then return token end end
  for token, loc in pairs(LOCALIZED_CLASS_NAMES_FEMALE or {}) do if loc==localized then return token end end
  return nil
end

local function ApplyIconsToRow(row, entry)
  local function normalizeGender(g) if g==3 or g=="female" then return "female" end return "male" end
  local function setRaceIcon(raceFile, gender)
    if not raceFile then return false end
    local lower = string.lower(raceFile or "")
    local raceAlias = { scourge="undead", nightelf="nightelf", highmountaintauren="highmountaintauren", lightforgeddraenei="lightforgeddraenei",
      voidelf="voidelf", magharorc="magharorc", darkirondwarf="darkirondwarf", ["kul tiran"]="kultiran", kultiran="kultiran",
      zandalaritroll="zandalaritroll", mechagnome="mechagnome", dracthyr="dracthyr" }
    lower = (raceAlias[lower] or lower):gsub("%s+","")
    local gSuffix = normalizeGender(gender)
    local candidates = {
      ("raceicon-%s-%s"):format(lower, gSuffix),
      ("raceicon32-%s-%s"):format(lower, gSuffix),
      ("raceicon64-%s-%s"):format(lower, gSuffix),
      ("raceicon-%s"):format(lower), ("raceicon32-%s"):format(lower), ("raceicon64-%s"):format(lower),
    }
    for _, atlas in ipairs(candidates) do
      if row.raceIcon:SetAtlas(atlas, true) then
        row.raceIcon:SetTexCoord(0.06,0.94,0.06,0.94); row.raceIcon:SetSize(ICON_SIZE, ICON_SIZE); row.raceIcon:Show(); return true
      end
    end
    return false
  end

  if not setRaceIcon(entry.raceFile, entry.gender) then
    if entry.guid == UnitGUID("player") then
      local myRaceFile = select(2, UnitRace("player")); local myGender = UnitSex("player")
      if not setRaceIcon(myRaceFile, myGender) then row.raceIcon:Hide() end
    else row.raceIcon:Hide() end
  end

  local classToken = entry.classFile or LocalizedClassToFileToken(entry.classLocalized)
  if classToken then
    local tl, tu = string.lower(classToken), string.upper(classToken)
    local atlasCandidates = { ("classicon-%s"):format(tl), ("GarrMission_ClassIcon-%s"):format(tl) }
    local set=false
    for _, atlas in ipairs(atlasCandidates) do
      if row.classIcon:SetAtlas(atlas, true) then
        row.classIcon:SetTexCoord(0.06,0.94,0.06,0.94); row.classIcon:SetSize(ICON_SIZE, ICON_SIZE); row.classIcon:Show(); set=true; break
      end
    end
    if not set then
      local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[tu]
      if coords then
        row.classIcon:SetAtlas(nil)
        row.classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        row.classIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        row.classIcon:SetSize(ICON_SIZE, ICON_SIZE); row.classIcon:Show(); set=true
      end
    end
    if not set then row.classIcon:Hide() end
  else row.classIcon:Hide() end
end

local function CollectGuildData()
  local data = {}
  if not IsInGuild() then return data end
  if C_GuildInfo and C_GuildInfo.GuildRoster then C_GuildInfo.GuildRoster() else GuildRoster() end
  local total = GetNumGuildMembers() or 0
  local db = EnsureDefaults(); ONLY_ONLINE = db.onlyOnline and true or false

  for i=1,total do
    local name, _, _, _, classLocalized, _, _, _, isOnline, _, classFileName, _, _, _, _, guid = GetGuildRosterInfo(i)
    if not classLocalized or not classFileName then local info={GetGuildRosterInfo(i)}; classLocalized=classLocalized or info[5]; classFileName=classFileName or info[11] or info[12]; guid=guid or info[#info] end
    if name then
      local fullName = name
      if not fullName:find("-", 1, true) then local rn=GetNormalizedRealmName(); if rn then fullName=fullName.."-"..rn:gsub("^%l",string.upper) end end
      fullName = fullName:gsub("%-(%l)", function(a) return "-"..a:upper() end)
      if (not ONLY_ONLINE) or isOnline then
        if FGT:IsDebug() then debugPrint((L.debug_fullname or "[DEBUG] fullName:"), fullName, "GUID:", guid or "nil") end
        local rioProfile = GetRIOProfile(fullName)

        local raceFile, gender
        if guid and GetPlayerInfoByGUID then
          local _,_,_, gClassFile, _, gRaceFile, gSex = GetPlayerInfoByGUID(guid)
          raceFile = gRaceFile or nil; gender = gSex or nil; classFileName = classFileName or gClassFile
        end
        if (not classFileName) and classLocalized then classFileName = LocalizedClassToFileToken(classLocalized) end

        if (not raceFile or not gender) and guid then
          local cached = EnsureDefaults().raceCache[guid]
          if cached then raceFile = raceFile or cached.raceFile; gender = gender or cached.gender end
        end

        table.insert(data, {
          name           = name:gsub("%-.*$", ""),
          fullName       = fullName,
          rioProfile     = rioProfile,
          rio            = GetRIOForUnit(rioProfile),
          isOnline       = isOnline and true or false,
          classLocalized = classLocalized,
          classFile      = classFileName,
          raceFile       = raceFile,
          gender         = gender,
          guid           = guid,
        })
      end
    end
  end

  local myName, myRealm = UnitFullName("player")
  local myFull = (myRealm and myRealm ~= "") and (myName .. "-" .. myRealm) or myName
  local myProfile = GetRIOProfile(myFull or myName)
  local _, myClassToken = UnitClassBase("player")
  local myGender = UnitSex("player")
  local myRaceFile = select(2, UnitRace("player"))
  local myGUID = UnitGUID("player")
  if myGUID and myRaceFile and myGender then EnsureDefaults().raceCache[myGUID] = { raceFile = myRaceFile, gender = myGender } end

  return data, { name=myName, fullName=myFull, rioProfile=myProfile, rio=GetRIOForUnit(myProfile), isOnline=true, classFile=myClassToken, raceFile=myRaceFile, gender=myGender, guid=myGUID }
end

local function FGT_GetScoreColor(score)
  if not tonumber(score) then return 1,1,1 end
  score = tonumber(score)
  if score >= 3000 then return 1.00, 0.50, 0.00
  elseif score >= 2500 then return 0.64, 0.21, 0.93
  elseif score >= 2000 then return 0.26, 0.59, 1.00
  elseif score >= 1500 then return 0.12, 1.00, 0.00
  elseif score >= 1000 then return 1.00, 1.00, 0.00
  else return 0.7, 0.7, 0.7 end
end
local function FGT_SetScoreCell(fs, score)
  fs:SetFontObject("QuestFontNormalSmall")
  local s = tostring(score or "N/A"); fs:SetText(s)
  local r,g,b = FGT_GetScoreColor(score); fs:SetTextColor(r,g,b,1)
end

Populate = function(frame)
  local content = frame.content
  for i = #content.rows, 1, -1 do if content.rows[i] then content.rows[i]:Hide(); content.rows[i]=nil end end
  FGT_EnsureMapIndex()

  local guildData, me = CollectGuildData()
  if (#guildData == 0) and (not me or not me.rio) then debugPrint(L.debug_populate_rows or "[DEBUG] Populate: 0 rows (no guild data/RIO)"); return end

  local headerRow = frame.ensureRow(1); headerRow:ClearAllPoints(); headerRow:SetPoint("TOPLEFT", 12, 0); headerRow:SetHeight(0.1)

  local selfInList = false
  if me then
    local selfGUID = me.guid or UnitGUID("player")
    for _, entry in ipairs(guildData) do
      if (selfGUID and entry.guid == selfGUID) or (me.fullName and entry.fullName == me.fullName) then
        entry.rioProfile = me.rioProfile or entry.rioProfile
        entry.rio        = me.rio or entry.rio
        entry.classFile  = entry.classFile or me.classFile
        entry.raceFile   = me.raceFile
        entry.gender     = me.gender
        selfInList = true; break
      end
    end
  end

  table.sort(guildData, function(a,b)
    if a.isOnline ~= b.isOnline then return a.isOnline and not b.isOnline end
    local sa = tonumber(a.rio and a.rio.mplusScore) or -1
    local sb = tonumber(b.rio and b.rio.mplusScore) or -1
    if sa ~= sb then return sa > sb end
    return (a.name or "") < (b.name or "")
  end)

  local rowIndex = 2
  for _, entry in ipairs(guildData) do
    local r = frame.ensureRow(rowIndex); r:Show(); r._entry = entry
    ApplyIconsToRow(r, entry)
    r.cols[1]:SetFontObject("GameFontHighlightSmall"); r.cols[1]:SetText(entry.name or "?")
    if entry.isOnline then r.cols[1]:SetTextColor(0.20,0.95,0.30,1) else r.cols[1]:SetTextColor(0.95,0.30,0.30,1) end
    r.cols[1]:SetShadowColor(0,0,0,1); r.cols[1]:SetShadowOffset(1,-1)

    r.nameBtn:SetScript("OnEnter", function(selfBtn) FGT:ShowMemberTooltip(selfBtn, entry.name or "?", entry.rioProfile) end)
    r.nameBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local runs     = entry.rio and entry.rio.runs or "N/A"
    local score    = entry.rio and entry.rio.mplusScore or "N/A"
    local raidText = (entry.rio and entry.rio.raid or "N/A") .. (entry.rio and entry.rio.raidDifficulty or "")
    r.cols[2]:SetFontObject("QuestFontNormalSmall"); r.cols[2]:SetText(tostring(runs))
    FGT_SetScoreCell(r.cols[3], score)
    r.cols[4]:SetFontObject("QuestFontNormalSmall"); r.cols[4]:SetText(tostring(raidText))

    if FGT:IsDebug() then debugPrint("Row", rowIndex-1, entry.fullName or "?", "score:", tostring(score)) end
    rowIndex = rowIndex + 1
  end

  if (me and me.rio) and not selfInList then
    local r = frame.ensureRow(rowIndex); r:Show(); r._entry = me
    ApplyIconsToRow(r, me)
    r.cols[1]:SetFontObject("DialogButtonHighlightText"); r.cols[1]:SetText(me.name)
    r.cols[1]:SetTextColor(0.20,0.95,0.30,1); r.cols[1]:SetShadowColor(0,0,0,1); r.cols[1]:SetShadowOffset(1,-1)
    r.nameBtn:SetScript("OnEnter", function(selfBtn) FGT:ShowMemberTooltip(selfBtn, me.name or "?", me.rioProfile) end)
    r.nameBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    r.cols[2]:SetFontObject("QuestFontNormalSmall"); r.cols[2]:SetText(tostring(me.rio.runs or "N/A"))
    FGT_SetScoreCell(r.cols[3], me.rio.mplusScore or "N/A")
    local raidText = (me.rio.raid or "N/A") .. (me.rio.raidDifficulty or "")
    r.cols[4]:SetFontObject("QuestFontNormalSmall"); r.cols[4]:SetText(tostring(raidText))
    rowIndex = rowIndex + 1
  end

  local totalRows = (rowIndex - 2) + 1
  content:SetHeight(totalRows * ROW_HEIGHT + 20)
end

-- Events / Init
local function SafeRegisterEvent(frame, event) local ok=pcall(frame.RegisterEvent, frame, event); if not ok then debugPrint("skipped event:", event) end end
FGT:RegisterEvent("ADDON_LOADED")
FGT:RegisterEvent("PLAYER_LOGIN")
FGT:RegisterEvent("PLAYER_ENTERING_WORLD")
FGT:RegisterEvent("PLAYER_GUILD_UPDATE")
FGT:RegisterEvent("GUILD_ROSTER_UPDATE")
SafeRegisterEvent(FGT, "RAIDERIO_DATABASE_LOADED")
SafeRegisterEvent(FGT, "RAIDERIO_PLAYER_PROFILE_UPDATED")
SafeRegisterEvent(FGT, "RAIDERIO_SCORE_UPDATED")

function FGT:ADDON_LOADED(name)
  if name ~= ADDON_NAME then return end
  local db = EnsureDefaults()
  ONLY_ONLINE = db.onlyOnline and true or false
  self:RegisterMinimap()
  debugPrint(L.debug_event or "[DEBUG] ADDON_LOADED")
end

function FGT:PLAYER_ENTERING_WORLD(_, isReloadingUi) isReloading = isReloadingUi; debugPrint(L.debug_event or "[DEBUG] PLAYER_ENTERING_WORLD", isReloading and "(reload)" or "") end

function FGT:PLAYER_LOGIN()
  debugPrint(L.debug_event or "[DEBUG] PLAYER_LOGIN")
  C_Timer.After(0.2, function() FGT_BuildMapIndex(); debugPrint("[DEBUG] MapIndex built (0.2s)") end)
  C_Timer.After(1.0, function() if not mainFrame then mainFrame = CreateWindow() end; FGT_BuildMapIndex(); Populate(mainFrame); debugPrint("[DEBUG] Populate after 1.0s") end)
  C_Timer.After(5.0,  function() FGT_BuildMapIndex(); if mainFrame then Populate(mainFrame) end; debugPrint("[DEBUG] Populate after 5.0s") end)
  C_Timer.After(12.0, function() FGT_BuildMapIndex(); if mainFrame then Populate(mainFrame) end; debugPrint("[DEBUG] Populate after 12.0s") end)
  C_Timer.After(0.3, function() self:WarnIfNoRegionDB() end) -- rote Chatwarnung bei fehlender Region-DB
end

function FGT:PLAYER_GUILD_UPDATE() debugPrint(L.debug_event or "[DEBUG] PLAYER_GUILD_UPDATE"); if mainFrame then Populate(mainFrame) end end
function FGT:GUILD_ROSTER_UPDATE() debugPrint(L.debug_event or "[DEBUG] GUILD_ROSTER_UPDATE"); if mainFrame then Populate(mainFrame) end end
function FGT:RAIDERIO_DATABASE_LOADED()        debugPrint(L.debug_event or "[DEBUG] RAIDERIO_DATABASE_LOADED");        if mainFrame then C_Timer.After(0.5, function() Populate(mainFrame) end) end end
function FGT:RAIDERIO_PLAYER_PROFILE_UPDATED() debugPrint(L.debug_event or "[DEBUG] RAIDERIO_PLAYER_PROFILE_UPDATED"); if mainFrame then C_Timer.After(0.1, function() Populate(mainFrame) end) end end
function FGT:RAIDERIO_SCORE_UPDATED()          debugPrint(L.debug_event or "[DEBUG] RAIDERIO_SCORE_UPDATED");          if mainFrame then C_Timer.After(0.1, function() Populate(mainFrame) end) end end

-- ============================================================================
-- Slash (inkl. neue /fgt loaddb & /fgt db; alte Befehle bleiben kompatibel)
local function FGT_Bool(b) return b and "true" or "false" end
local function FGT_DebugRIOEnv()
  local rgn = (GetCurrentRegionName and GetCurrentRegionName()) or (GetCVar and GetCVar("portal")) or "?"
  local isCore = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("RaiderIO")
  local vCore  = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("RaiderIO","Version")
  print("|cff33ff99FGT:|r DebugEnv ---------")
  print("Region (client):", rgn)
  print("RaiderIO loaded:", FGT_Bool(isCore), "ver:", vCore or "nil")
  local mods, tag = FGT_RegionModules()
  for _,a in ipairs(mods) do
    local loaded = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(a)
    local ver    = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(a,"Version")
    print(("[%s] %s:"):format(tag,a), FGT_Bool(loaded), "ver:", ver or "nil")
  end
end

local function FGT_TestProfile(name)
  if not name or name=="" then print("|cff33ff99FGT:|r usage: /fgt profile Name-Realm"); return end
  if not RaiderIO or not RaiderIO.GetProfile then print("|cff33ff99FGT:|r RaiderIO API not ready"); return end
  local p = RaiderIO:GetProfile(name)
  print("|cff33ff99FGT:|r Profile("..name.."):", type(p)=="table" and "OK (table)" or "nil")
end

SLASH_FGT1 = "/fgt"
SlashCmdList["FGT"] = function(msg)
  msg = (msg and msg:lower() or "")
  if msg == "minimap" or msg == "mm" then
    local db = EnsureDefaults(); FGT:SetMinimapShown(db.minimap.hide); return
  elseif msg == "options" or msg == "opt" or msg == "config" then
    if Settings and Settings.OpenToCategory then Settings.OpenToCategory(L.title)
    elseif InterfaceOptionsFrame_OpenToCategory then InterfaceOptionsFrame_OpenToCategory(L.title); InterfaceOptionsFrame_OpenToCategory(L.title) end
    return
  elseif msg == "debug" then
    FGT:DebugEnable(not FGT:IsDebug()); return
  elseif msg == "debugenv" then
    FGT_DebugRIOEnv(); return
  elseif msg == "loaddb" or msg == "loadeu" then -- loadeu bleibt kompatibel
    FGT:EnsureRegionDBLoaded(); return
  elseif msg == "db" or msg == "eu" then -- eu bleibt kompatibel
    local ok, missing, tag = FGT:CheckRegionDBLoaded()
    if ok then
      print("|cff33ff99FGT:|r "..(L_KEY("db_status_ok","status_ok") or "DB loaded").." ("..tag..")")
    else
      print("|cffff5555FGT:|r "..(L_KEY("db_status_missing","status_missing") or "DB missing: %s"):format(table.concat(missing,", ")).." ("..tag..")")
    end
    return
  end

  local profArg = msg:match("^profile%s+(.+)")
  if profArg then profArg = profArg:gsub("%-(%l)", function(a) return "-"..a:upper() end); FGT_TestProfile(profArg); return end
  FGT:Toggle()
end

-- ============================================================================
-- Minimap (LDB + LibDBIcon)
function FGT:RegisterMinimap()
  local ldb     = LibStub and LibStub("LibDataBroker-1.1", true)
  local ldbIcon = LibStub and LibStub("LibDBIcon-1.0", true)
  if not (ldb and ldbIcon) then
    if self.IsDebug and self:IsDebug() then print("|cff33ff99FGT:|r LDB/LibDBIcon missing (OptionalDeps).") end
    return
  end

  local dataObj = ldb:NewDataObject("FastGuildTracker", {
    type  = "launcher",
    text  = "FGT",
    icon  = "Interface\\Icons\\INV_Banner_03",
    OnClick = function(_, button)
      if button == "LeftButton" then
        FGT:Toggle()
      elseif button == "RightButton" then
        if L.helpCmd then print("|cff33ff99FGT:|r "..L.helpCmd) end
      end
    end,
    OnTooltipShow = function(tt)
      -- Header
      tt:AddLine(L.title or "FastGuildTracker")
      tt:AddLine(L.leftClick or "Left-click: toggle window", 0.2, 1.0, 0.2)
      tt:AddLine(L.rightClick or "Right-click: help",        0.8, 0.8, 0.8)
      tt:AddLine(" ")

      -- Region + DB-Status
      local tag = (type(FGT_GetRegionTag)=="function" and FGT_GetRegionTag()) or "?"
      local ok, missing = false, nil
      if type(FGT.CheckRegionDBLoaded) == "function" then
        ok, missing = FGT:CheckRegionDBLoaded()
      end

      tt:AddLine(("Region: %s"):format(tag), 0.6, 0.8, 1.0)

      if ok then
        tt:AddLine(L.db_status_ok or "Region DB loaded", 0.2, 1.0, 0.2)
      else
        local miss = (type(missing)=="table" and table.concat(missing, ", ")) or "?"
        tt:AddLine((L.db_status_missing or "Region DB missing: %s"):format(miss), 1.0, 0.25, 0.25)
        tt:AddLine("/fgt loaddb", 1.0, 0.85, 0.2)
      end
    end,
  })

  if dataObj then
    local db = EnsureDefaults()
    ldbIcon:Register("FastGuildTracker", dataObj, db.minimap)
    FGT.ldbIcon = ldbIcon

    -- Nudge/Icon-Tuning (wie zuvor)
    local btn = ldbIcon.GetMinimapButton and ldbIcon:GetMinimapButton("FastGuildTracker")
    if btn and btn.icon then
      btn.icon:ClearAllPoints()
      btn.icon:SetPoint("CENTER", btn, "CENTER", db.minimapNudge.x or 0, db.minimapNudge.y or 0)
      btn.icon:SetSize(19, 19)
      btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    if db.minimap.hide then ldbIcon:Hide("FastGuildTracker") else ldbIcon:Show("FastGuildTracker") end
  end
end
