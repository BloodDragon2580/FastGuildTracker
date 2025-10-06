local ADDON_NAME = ...
local ADDON_DB   = "FastGuildTrackerDB"
local L          = _G.FastGuildTrackerLocale or { title="FastGuildTracker" }

-- ============================================================================
-- Config
local DEBUG_MODE         = false
local TABLE_COLUMN_NUM   = 4
local TABLE_COLUMN_WIDTH = 150
local ROW_HEIGHT         = 24
local FADE_WHILE_MOVING  = true
local ONLY_ONLINE        = true
local NAME_ICON_PAD      = 34   -- Platz links für beide Icons (+4px Abstand)
local ICON_SIZE          = 14   -- kleinere Icons
-- ============================================================================

local function debugPrint(...) if DEBUG_MODE then print("|cff33ff99FGT:|r", ...) end end

-- SavedVariables defaults
local function EnsureDefaults()
  _G[ADDON_DB] = _G[ADDON_DB] or {}
  local db = _G[ADDON_DB]
  db.minimap    = db.minimap or { hide = false }
  if db.showMinimap == nil then db.showMinimap = true end
  if db.onlyOnline  == nil then db.onlyOnline  = true end
  db.minimapNudge = db.minimapNudge or { x = 0, y = 0 }
  db.raceCache   = db.raceCache   or {}   -- <<< CACHE: GUID -> { raceFile, gender }
  return db
end

-- Addon table
local FGT = CreateFrame("Frame"); _G.FastGuildTracker = FGT
FGT:SetScript("OnEvent", function(self, event, ...) if self[event] then self[event](self, ...) end end)

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
-- Optional: Nudge API für Minimap-Icon
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
-- Modernes Fenster (Custom, kein PortraitFrameTemplate)
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
  f:Hide() -- nicht auto-öffnen

  -- Hintergrund (modern)
  local bg = f:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0.08, 0.09, 0.10, 0.95)

  local border = CreateFrame("Frame", nil, f, "BackdropTemplate")
  border:SetPoint("TOPLEFT", 1, -1)
  border:SetPoint("BOTTOMRIGHT", -1, 1)
  border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
  border:SetBackdropBorderColor(0, 0, 0, 1)

  local shadow = f:CreateTexture(nil, "BACKGROUND", nil, -1)
  shadow:SetPoint("TOPLEFT", -6, 6)
  shadow:SetPoint("BOTTOMRIGHT", 6, -6)
  shadow:SetTexture("Interface\\Buttons\\WHITE8x8")
  shadow:SetVertexColor(0, 0, 0, 0.35)

  -- Titlebar
  local bar = f:CreateTexture(nil, "ARTWORK")
  bar:SetPoint("TOPLEFT", 0, 0)
  bar:SetPoint("TOPRIGHT", 0, 0)
  bar:SetHeight(36)
  bar:SetColorTexture(0.12, 0.14, 0.18, 1)

  local underline = f:CreateTexture(nil, "ARTWORK")
  underline:SetPoint("TOPLEFT", 0, -36)
  underline:SetPoint("TOPRIGHT", 0, -36)
  underline:SetHeight(1)
  underline:SetColorTexture(0, 0, 0, 1)

  -- Titel (zentriert)
  local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", f, "TOP", 0, -9)
  title:SetText(L.title or "FastGuildTracker")
  title:SetJustifyH("CENTER")
  title:SetTextColor(1, 1, 1, 1)
  title:SetShadowColor(0, 0, 0, 1)
  title:SetShadowOffset(1, -1)
  f.TitleText = title

  -- Close
  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 2, 2)
  close:SetScale(0.9)

  -- Header-Zeile
  local header = CreateFrame("Frame", nil, f)
  header:SetPoint("TOPLEFT", 12, -44)
  header:SetPoint("TOPRIGHT", -12, -44)
  header:SetHeight(26)

  local headerBg = header:CreateTexture(nil, "ARTWORK")
  headerBg:SetAllPoints()
  headerBg:SetColorTexture(0.16, 0.18, 0.22, 1)

  local headerLine = header:CreateTexture(nil, "ARTWORK")
  headerLine:SetPoint("BOTTOMLEFT")
  headerLine:SetPoint("BOTTOMRIGHT")
  headerLine:SetHeight(1)
  headerLine:SetColorTexture(0, 0, 0, 1)

  -- ScrollFrame + Content
  local scrollFrame = CreateFrame("ScrollFrame", "FastGuildTrackerScroll", f, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", 12, -72)
  scrollFrame:SetPoint("BOTTOMRIGHT", -28, 12)

  local content = CreateFrame("Frame", nil, scrollFrame)
  scrollFrame:SetScrollChild(content)
  content:SetSize(900, 800)
  content.rows = {}
  f.content = content

  -- Header-Texte
  local function CreateHeaderText(parent, x, text)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("LEFT", parent, "LEFT", x, 0)
    fs:SetWidth(TABLE_COLUMN_WIDTH)
    fs:SetJustifyH("LEFT")
    fs:SetText(text)
    fs:SetTextColor(1, 1, 1, 0.95)
    fs:SetShadowColor(0, 0, 0, 1)
    fs:SetShadowOffset(1, -1)
    return fs
  end

  f.header = header
  f.h1 = CreateHeaderText(header, 0,                      L.name_col   or "Name")
  f.h2 = CreateHeaderText(header, 1 * TABLE_COLUMN_WIDTH, L.runs_col   or "M+ Runs")
  f.h3 = CreateHeaderText(header, 2 * TABLE_COLUMN_WIDTH, L.rating_col or "M+ Rating")
  f.h4 = CreateHeaderText(header, 3 * TABLE_COLUMN_WIDTH, L.best_col   or "Best Raid Kill")

  -- gespeicherte Position
  local db = EnsureDefaults()
  if db.position then f:ClearAllPoints(); f:SetPoint(unpack(db.position)) end

  return f
end

CreateWindow = function()
  local frame = CreateModernContainer()

  -- Row-Factory
  local function ensureRow(idx)
    if frame.content.rows[idx] then return frame.content.rows[idx] end

    local row = CreateFrame("Frame", nil, frame.content)
    row:SetSize(TABLE_COLUMN_WIDTH * TABLE_COLUMN_NUM, ROW_HEIGHT)
    row:SetPoint("TOPLEFT", 12, -((idx-1) * ROW_HEIGHT))

    -- Zebra-Hintergrund
    if (idx % 2 == 0) then
      local z = row:CreateTexture(nil, "BACKGROUND")
      z:SetAllPoints()
      z:SetColorTexture(1, 1, 1, 0.02)
      row.zebra = z
    end

    -- Icons vor dem Namen
    row.raceIcon  = row:CreateTexture(nil, "ARTWORK")
    row.classIcon = row:CreateTexture(nil, "ARTWORK")
    row.raceIcon:SetSize(ICON_SIZE, ICON_SIZE)
    row.classIcon:SetSize(ICON_SIZE, ICON_SIZE)
    row.raceIcon:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.classIcon:SetPoint("LEFT", row.raceIcon, "RIGHT", 4, 0)

    row.cols = {}
    for j = 1, TABLE_COLUMN_NUM do
      local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      local xOffset = (j == 1) and (NAME_ICON_PAD) or ((j-1)*TABLE_COLUMN_WIDTH)
      fs:SetPoint("LEFT", xOffset, 0)
      fs:SetWidth(TABLE_COLUMN_WIDTH - ((j == 1) and NAME_ICON_PAD or 0))
      fs:SetJustifyH("LEFT")
      fs:SetTextColor(0.9, 0.9, 0.9, 1)
      fs:SetShadowColor(0,0,0,1)
      fs:SetShadowOffset(1, -1)
      row.cols[j] = fs
    end

    -- Interaktive Fläche für den Namen (Tooltip-Target)
    row.nameBtn = CreateFrame("Button", nil, row)
    row.nameBtn:SetPoint("LEFT", 0, 0)
    row.nameBtn:SetSize(TABLE_COLUMN_WIDTH, ROW_HEIGHT)
    row.nameBtn:SetScript("OnEnter", function(self)
      local e = row._entry
      if not e then return end
      FGT:ShowMemberTooltip(self, e.name or "?", e.rioProfile)
    end)
    row.nameBtn:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

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

-- ============================================================================
-- RaiderIO helpers

-- Holt das RaiderIO-Profil (voller Name inkl. Realm erforderlich)
local function GetRIOProfile(fullName)
  if not RaiderIO or not RaiderIO.GetProfile then return nil end
  if not fullName or fullName == "" then return nil end
  return RaiderIO:GetProfile(fullName) or RaiderIO.GetProfile(fullName)
end

-- M+ Basiswerte für Tabelle (robust)
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
  if raidProgress ~= "N/A" and raidDifficulty then
    raidDifficulty = " ["..raidDifficulty.."]"
  else
    raidDifficulty = ""
  end

  local runs, score = 0, "N/A"
  local mkp = profile.mythicKeystoneProfile
  if type(mkp) == "table" then
    for lvl=1,30 do
      local v = mkp["keystoneMilestone"..lvl]
      if type(v) == "number" then runs = runs + v end
    end
    score = mkp.currentScore or mkp.mainCurrentScore or mkp.previousScore or "N/A"
  end

  return { runs = runs, mplusScore = score, raid = raidProgress, raidDifficulty = raidDifficulty }
end

-- ===========================
-- Localized CM Map Index
-- ===========================
local FGT_MapIndex = nil

-- >>> NEU: Dekos entfernen (z.B. "(Mythic Keystone)", "+15") und normalisieren
local function FGT_StripKeystoneDecorations(s)
  if not s or s == "" then return s end
  s = s:gsub("%b()", "")             -- Klammerinhalte entfernen
  s = s:gsub("%+%d+", "")            -- "+15" usw.
  s = s:gsub("mythic keystone", "")
  s = s:gsub("mythic%+?", "")
  s = s:gsub("%s+", " ")
  s = s:match("^%s*(.-)%s*$")        -- trim
  return s
end

local function FGT_NormalizeName(s)
  if not s then return nil end
  s = FGT_StripKeystoneDecorations(s)
  s = s:lower()
  s = s:gsub("[^%w]", "")
  return s
end

local function FGT_BuildMapIndex()
  FGT_MapIndex = { byId = {}, byNorm = {} }
  if not C_ChallengeMode or not C_ChallengeMode.GetMapTable then return FGT_MapIndex end
  local ids = C_ChallengeMode.GetMapTable()
  if type(ids) ~= "table" then return FGT_MapIndex end

  for _, id in ipairs(ids) do
    local name = C_ChallengeMode.GetMapUIInfo and C_ChallengeMode.GetMapUIInfo(id) or nil
    if name and name ~= "" then
      local norm = FGT_NormalizeName(name)
      FGT_MapIndex.byId[id] = name
      if norm and norm ~= "" then
        FGT_MapIndex.byNorm[norm] = id
      end
    end
  end
  return FGT_MapIndex
end

local function FGT_EnsureMapIndex()
  if not FGT_MapIndex or (FGT_MapIndex and (not next(FGT_MapIndex.byId))) then
    FGT_BuildMapIndex()
  end
  return FGT_MapIndex
end

-- Optionale Aliase (engl. RIO-Namen/Shorts -> CM-MapID)
local FGT_EnglishAliases = {
  -- ["ataldazar"] = 244,
}

-- Versucht, einen lokalisierten Dungeon-Namen zu ermitteln
local function LocalizedDungeonNameFromRun(run)
  if type(run) ~= "table" then return nil end
  FGT_EnsureMapIndex()

  -- 0) Harte IDs
  local cmId = run.mapId or run.mapID or run.challengeMapID or run.challengeModeID
              or run.mapChallengeModeID or run.keystoneDungeonId or run.keystoneInstance
              or run.instanceChallengeModeID
  if type(cmId) == "number" and FGT_MapIndex and FGT_MapIndex.byId[cmId] then
    return FGT_MapIndex.byId[cmId]
  end

  -- 1) Zonen-/Instanz-ID → lokalisierter Kartenname
  local zoneOrInstanceId = run.instanceId or run.instanceID or run.zoneId or run.zoneID
  if type(zoneOrInstanceId) == "number" and C_Map and C_Map.GetMapInfo then
    local mi = C_Map.GetMapInfo(zoneOrInstanceId)
    if mi and mi.name and mi.name ~= "" then
      return mi.name
    end
  end

  -- 2) String-Kandidaten (engl.) → heuristisches Mapping auf lokalisierte Namen
  local raw = run.dungeonShort or run.zoneShort or run.mapName or run.name or run.dungeon or run.map
  if type(raw) == "string" and raw ~= "" then
    local cleaned = FGT_StripKeystoneDecorations(raw)
    local norm    = FGT_NormalizeName(cleaned)
    if norm and norm ~= "" and FGT_MapIndex then
      -- 2a) Alias
      local aliasId = FGT_EnglishAliases[norm]
      if aliasId and FGT_MapIndex.byId[aliasId] then
        return FGT_MapIndex.byId[aliasId]
      end
      -- 2b) exakter Norm-Match
      local id2 = FGT_MapIndex.byNorm[norm]
      if id2 and FGT_MapIndex.byId[id2] then
        return FGT_MapIndex.byId[id2]
      end
      -- 2c) fuzzy (ab 4 Zeichen)
      if #norm >= 4 then
        -- startswith bevorzugen
        for id3, locName in pairs(FGT_MapIndex.byId) do
          local nloc = FGT_NormalizeName(locName)
          if nloc and nloc:find("^"..norm) then
            return locName
          end
        end
        -- contains in beide Richtungen
        for id3, locName in pairs(FGT_MapIndex.byId) do
          local nloc = FGT_NormalizeName(locName)
          if nloc and (nloc:find(norm, 1, true) or norm:find(nloc, 1, true)) then
            return locName
          end
        end
      end
    end
    -- letzter Fallback: gereinigten (engl.) Namen zurückgeben
    return cleaned
  end

  return nil
end

-- Tooltip: Dungeons extrahieren (robust, mit Fallbacks & synthetischen Einträgen)
local function ExtractDungeonRunsFromProfile(profile)
  local out = {}
  if not profile or not profile.mythicKeystoneProfile then return out end
  local mkp = profile.mythicKeystoneProfile

  local function addRun(run)
    if type(run) ~= "table" then return end
    local level = run.level or run.keystoneLevel or run.keyLevel or run.mplusLevel or run.maxDungeonLevel
    local name  = LocalizedDungeonNameFromRun(run)
               or run.dungeonShort or run.zoneShort or run.mapName or run.name or run.dungeon or run.map
    if level and name then
      table.insert(out, { name = tostring(name), level = tonumber(level) or level })
    end
  end

  local preferred = { mkp.runs, mkp.bestRuns, mkp.sortedRuns, mkp.sortedDungeons }
  for _, list in ipairs(preferred) do
    if type(list) == "table" and #list > 0 then
      for _, r in ipairs(list) do addRun(r) end
      table.sort(out, function(a,b) return (tonumber(a.level) or 0) > (tonumber(b.level) or 0) end)
      return out
    end
  end

  if type(mkp.dungeons) == "table" then
    local had = false
    if #mkp.dungeons > 0 then
      for _, v in ipairs(mkp.dungeons) do
        if type(v) == "table" then addRun(v.best or v.bestRun or v.top or v.last or v.max); had = true end
      end
    else
      for _, v in pairs(mkp.dungeons) do
        if type(v) == "table" then addRun(v.best or v.bestRun or v.top or v.last or v.max); had = true end
      end
    end
    if had then
      table.sort(out, function(a,b) return (tonumber(a.level) or 0) > (tonumber(b.level) or 0) end)
      return out
    end
  end

  local more = { mkp.dungeonTimes, mkp.warbandDungeonTimes, mkp.warbandDungeons }
  for _, list in ipairs(more) do
    if type(list) == "table" then
      local found = false
      if #list > 0 then
        for _, v in ipairs(list) do if type(v) == "table" then addRun(v); found = true end end
      else
        for _, v in pairs(list) do if type(v) == "table" then addRun(v); found = true end end
      end
      if found then
        table.sort(out, function(a,b) return (tonumber(a.level) or 0) > (tonumber(b.level) or 0) end)
        return out
      end
    end
  end

  if type(mkp.maxDungeon) == "table" or tonumber(mkp.maxDungeonLevel) then
    local fake = {
      name  = (type(mkp.maxDungeon)=="table" and (mkp.maxDungeon.mapName or mkp.maxDungeon.dungeon or mkp.maxDungeon.name)) or "Best Dungeon",
      level = tonumber(mkp.maxDungeonLevel) or (type(mkp.maxDungeon)=="table" and (mkp.maxDungeon.level or mkp.maxDungeon.keyLevel)),
    }
    if fake.name and fake.level then
      table.insert(out, { name = tostring(fake.name), level = fake.level })
    end
  end

  table.sort(out, function(a,b) return (tonumber(a.level) or 0) > (tonumber(b.level) or 0) end)
  return out
end

-- Tooltip anzeigen
function FGT:ShowMemberTooltip(anchorFrame, unitNameDisplay, unitProfile)
  GameTooltip:SetOwner(anchorFrame, "ANCHOR_RIGHT")
  GameTooltip:ClearLines()
  FGT_EnsureMapIndex() -- <<< sicherstellen, dass Index verfügbar ist

  GameTooltip:AddLine(unitNameDisplay, 1, 1, 1)

  if not RaiderIO or not unitProfile then
    GameTooltip:AddLine(L.no_rio_detail or "RaiderIO data not available.", 1, 0.4, 0.4)
    GameTooltip:Show()
    return
  end

  local score = unitProfile.mythicKeystoneProfile and unitProfile.mythicKeystoneProfile.currentScore
  if score then
    GameTooltip:AddDoubleLine(L.mplus_score or "M+ Score", tostring(score), 0.8,0.8,0.8, 0,1,0.6)
  end

  local runs = ExtractDungeonRunsFromProfile(unitProfile)
  if #runs == 0 then
    GameTooltip:AddLine(L.no_rio_detail or "No detailed dungeon runs from RaiderIO.", 0.9, 0.75, 0.75)
  else
    GameTooltip:AddLine(L.dungeons_header or "Recent / Best Dungeons:", 0.2, 1, 0.2)
    local maxLines = 8
    for i = 1, math.min(#runs, maxLines) do
      local r = runs[i]
      GameTooltip:AddDoubleLine(("• %s"):format(r.name), ("+%s"):format(r.level), 0.9,0.9,0.9, 0.9,0.9,0.9)
    end
    if #runs > maxLines then
      GameTooltip:AddLine((L.and_more or "...and %d more"):format(#runs - maxLines), 0.7, 0.7, 0.7)
    end
  end

  GameTooltip:Show()
end

-- ============================================================================
-- Klassen/Rassen-Auflösung

local function LocalizedClassToFileToken(localized)
  if not localized then return nil end
  for token, loc in pairs(LOCALIZED_CLASS_NAMES_MALE or {}) do
    if loc == localized then return token end
  end
  for token, loc in pairs(LOCALIZED_CLASS_NAMES_FEMALE or {}) do
    if loc == localized then return token end
  end
  return nil
end

-- Setzt Race- und Class-Icon vor den Namen (robust; inkl. Fallbacks/Aliases)
local function ApplyIconsToRow(row, entry)
  -- RACE ICON
  local function normalizeGender(g)
    if g == 3 or g == "female" then return "female" end
    return "male"
  end

  local function setRaceIcon(raceFile, gender)
    if not raceFile then return false end
    local lower = string.lower(raceFile or "")

    -- Aliase für abweichende Race-Keys
    local raceAlias = {
      scourge            = "undead",
      nightelf           = "nightelf",
      highmountaintauren = "highmountaintauren",
      lightforgeddraenei = "lightforgeddraenei",
      voidelf            = "voidelf",
      magharorc          = "magharorc",
      darkirondwarf      = "darkirondwarf",
      ["kul tiran"]      = "kultiran",
      kultiran           = "kultiran",
      zandalaritroll     = "zandalaritroll",
      mechagnome         = "mechagnome",
      dracthyr           = "dracthyr",
    }
    lower = (raceAlias[lower] or lower):gsub("%s+", "")

    local gSuffix = normalizeGender(gender)

    local candidates = {
      ("raceicon-%s-%s"):format(lower, gSuffix),
      ("raceicon32-%s-%s"):format(lower, gSuffix),
      ("raceicon64-%s-%s"):format(lower, gSuffix),
      ("raceicon-%s"):format(lower),
      ("raceicon32-%s"):format(lower),
      ("raceicon64-%s"):format(lower),
    }

    for _, atlas in ipairs(candidates) do
      if row.raceIcon:SetAtlas(atlas, true) then
        row.raceIcon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
        row.raceIcon:SetSize(ICON_SIZE, ICON_SIZE)
        row.raceIcon:Show()
        return true
      end
    end
    return false
  end

  if not setRaceIcon(entry.raceFile, entry.gender) then
    if entry.guid == UnitGUID("player") then
      local myRaceFile = select(2, UnitRace("player"))
      local myGender = UnitSex("player")
      if not setRaceIcon(myRaceFile, myGender) then
        row.raceIcon:Hide()
      end
    else
      row.raceIcon:Hide()
    end
  end

  -- CLASS ICON
  local classToken = entry.classFile or LocalizedClassToFileToken(entry.classLocalized)
  if classToken then
    local tokenLower = string.lower(classToken)
    local tokenUpper = string.upper(classToken)

    local atlasCandidates = {
      ("classicon-%s"):format(tokenLower),
      ("GarrMission_ClassIcon-%s"):format(tokenLower),
    }
    local set = false
    for _, atlas in ipairs(atlasCandidates) do
      if row.classIcon:SetAtlas(atlas, true) then
        row.classIcon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
        row.classIcon:SetSize(ICON_SIZE, ICON_SIZE)
        row.classIcon:Show()
        set = true
        break
      end
    end

    if not set then
      local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[tokenUpper]
      if coords then
        row.classIcon:SetAtlas(nil)
        row.classIcon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
        row.classIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        row.classIcon:SetSize(ICON_SIZE, ICON_SIZE)
        row.classIcon:Show()
        set = true
      end
    end

    if not set then
      row.classIcon:Hide()
    end
  else
    row.classIcon:Hide()
  end
end

-- ============================================================================
-- Daten sammeln
local function CollectGuildData()
  local data = {}
  if not IsInGuild() then return data end

  if C_GuildInfo and C_GuildInfo.GuildRoster then C_GuildInfo.GuildRoster() else GuildRoster() end

  local total = GetNumGuildMembers() or 0
  local db = EnsureDefaults()
  ONLY_ONLINE = db.onlyOnline and true or false

  for i=1,total do
    local name, rank, rankIndex, level, classLocalized, zone, note, officernote, isOnline, status, classFileName, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid =
      GetGuildRosterInfo(i)

    if not classLocalized or not classFileName then
      local info = { GetGuildRosterInfo(i) }
      classLocalized  = classLocalized  or info[5]
      classFileName   = classFileName   or info[11] or info[12]
      guid            = guid            or info[#info]
    end

    if name then
      local fullName = name
      if not fullName:find("-", 1, true) then
        local rn = GetNormalizedRealmName()
        if rn then fullName = fullName .. "-" .. rn:gsub("^%l", string.upper) end
      end

      if (not ONLY_ONLINE) or isOnline then
        local rioProfile = GetRIOProfile(fullName)

        local raceFile, gender
        if guid and GetPlayerInfoByGUID then
          local gName, gRealm, gClassName, gClassFile, gRaceName, gRaceFile, gSex = GetPlayerInfoByGUID(guid)
          raceFile = gRaceFile or nil
          gender   = gSex      or nil
          classFileName = classFileName or gClassFile
        end

        if (not classFileName) and classLocalized then
          classFileName = LocalizedClassToFileToken(classLocalized)
        end

        -- CACHE: Offline-Fall -> aus Cache holen, wenn nichts da
        if (not raceFile or not gender) and guid then
          local cached = EnsureDefaults().raceCache[guid]
          if cached then
            raceFile = raceFile or cached.raceFile
            gender   = gender   or cached.gender
          end
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

        -- CACHE: Alles was wir wissen, merken wir uns
        if guid and raceFile and gender then
          EnsureDefaults().raceCache[guid] = { raceFile = raceFile, gender = gender }
        end
      end
    end
  end

  -- Eigener Spieler korrekt: Name-Realm + GUID
  local myName, myRealm = UnitFullName("player")
  local myFull = (myRealm and myRealm ~= "") and (myName .. "-" .. myRealm) or myName
  local myProfile = GetRIOProfile(myFull or myName)

  local _, myClassToken = UnitClassBase("player")
  local myGender = UnitSex("player")
  local myRaceFile = select(2, UnitRace("player"))
  local myGUID = UnitGUID("player")

  -- CACHE: Eigenen Spieler sofort cachen
  if myGUID and myRaceFile and myGender then
    EnsureDefaults().raceCache[myGUID] = { raceFile = myRaceFile, gender = myGender }
  end

  return data, {
    name       = myName,
    fullName   = myFull,
    rioProfile = myProfile,
    rio        = GetRIOForUnit(myProfile),
    isOnline   = true,
    classFile  = myClassToken,
    raceFile   = myRaceFile,
    gender     = myGender,
    guid       = myGUID,
  }
end

-- ============================================================================
-- Rendering
local function setCell(fs, text)
  fs:SetFontObject("QuestFontNormalSmall")
  fs:SetText(tostring(text or ""))
end

Populate = function(frame)
  local content = frame.content
  for i = #content.rows, 1, -1 do
    if content.rows[i] then content.rows[i]:Hide(); content.rows[i] = nil end
  end

  FGT_EnsureMapIndex()

  local guildData, me = CollectGuildData()
  if (#guildData == 0) and (not me or not me.rio) then return end

  local headerRow = frame.ensureRow(1)
  headerRow:ClearAllPoints()
  headerRow:SetPoint("TOPLEFT", 12, 0)
  headerRow:SetHeight(0.1)

  -- vorhandenen Eintrag für dich ggf. anreichern
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
        selfInList = true
        break
      end
    end
  end

  -- >>> NEU: Online zuerst sortieren (dann Score desc, dann Name asc)
  table.sort(guildData, function(a, b)
    if a.isOnline ~= b.isOnline then
      return a.isOnline and not b.isOnline
    end
    local sa = tonumber(a.rio and a.rio.mplusScore) or -1
    local sb = tonumber(b.rio and b.rio.mplusScore) or -1
    if sa ~= sb then
      return sa > sb
    end
    return (a.name or "") < (b.name or "")
  end)

  local rowIndex = 2

  for _, entry in ipairs(guildData) do
    local r = frame.ensureRow(rowIndex); r:Show()
    r._entry = entry

    ApplyIconsToRow(r, entry)

    r.cols[1]:SetFontObject("GameFontHighlightSmall")
    r.cols[1]:SetText(entry.name or "?")
    if entry.isOnline then
      r.cols[1]:SetTextColor(0.20, 0.95, 0.30, 1)
    else
      r.cols[1]:SetTextColor(0.95, 0.30, 0.30, 1)
    end
    r.cols[1]:SetShadowColor(0,0,0,1)
    r.cols[1]:SetShadowOffset(1,-1)

    r.nameBtn:SetScript("OnEnter", function(selfBtn)
      FGT:ShowMemberTooltip(selfBtn, entry.name or "?", entry.rioProfile)
    end)
    r.nameBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local runs     = entry.rio and entry.rio.runs or "N/A"
    local score    = entry.rio and entry.rio.mplusScore or "N/A"
    local raidText = (entry.rio and entry.rio.raid or "N/A") .. (entry.rio and entry.rio.raidDifficulty or "")
    r.cols[2]:SetFontObject("QuestFontNormalSmall"); r.cols[2]:SetText(tostring(runs))
    r.cols[3]:SetFontObject("QuestFontNormalSmall"); r.cols[3]:SetText(tostring(score))
    r.cols[4]:SetFontObject("QuestFontNormalSmall"); r.cols[4]:SetText(tostring(raidText))

    rowIndex = rowIndex + 1
  end

  if (me and me.rio) and not selfInList then
    local r = frame.ensureRow(rowIndex); r:Show()
    r._entry = me

    ApplyIconsToRow(r, me)

    r.cols[1]:SetFontObject("DialogButtonHighlightText")
    r.cols[1]:SetText(me.name)
    r.cols[1]:SetTextColor(0.20, 0.95, 0.30, 1)
    r.cols[1]:SetShadowColor(0,0,0,1)
    r.cols[1]:SetShadowOffset(1,-1)

    r.nameBtn:SetScript("OnEnter", function(selfBtn)
      FGT:ShowMemberTooltip(selfBtn, me.name or "?", me.rioProfile)
    end)
    r.nameBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    r.cols[2]:SetFontObject("QuestFontNormalSmall"); r.cols[2]:SetText(tostring(me.rio.runs or "N/A"))
    r.cols[3]:SetFontObject("QuestFontNormalSmall"); r.cols[3]:SetText(tostring(me.rio.mplusScore or "N/A"))
    local raidText = (me.rio.raid or "N/A") .. (me.rio.raidDifficulty or "")
    r.cols[4]:SetFontObject("QuestFontNormalSmall"); r.cols[4]:SetText(tostring(raidText))

    rowIndex = rowIndex + 1
  end

  local totalRows = (rowIndex - 2) + 1
  content:SetHeight(totalRows * ROW_HEIGHT + 20)
end

-- Sichere Event-Registrierung (ignoriert unbekannte Events)
local function SafeRegisterEvent(frame, event)
  local ok, err = pcall(frame.RegisterEvent, frame, event)
  if not ok and DEBUG_MODE then
    print("|cff33ff99FGT:|r skipped event:", event, "->", err)
  end
end

-- ============================================================================
-- Events / Init
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
end

function FGT:PLAYER_ENTERING_WORLD(_, isReloadingUi) isReloading = isReloadingUi end

-- >>> ANGEPASST: MapIndex sehr früh & wiederholt bauen, dann Populate
function FGT:PLAYER_LOGIN()
  C_Timer.After(0.2, FGT_BuildMapIndex)
  C_Timer.After(1.0, function()
    if not mainFrame then mainFrame = CreateWindow() end
    FGT_BuildMapIndex()
    Populate(mainFrame)
  end)
  C_Timer.After(5.0,  function() FGT_BuildMapIndex(); if mainFrame then Populate(mainFrame) end end)
  C_Timer.After(12.0, function() FGT_BuildMapIndex(); if mainFrame then Populate(mainFrame) end end)
end

function FGT:PLAYER_GUILD_UPDATE() if mainFrame then Populate(mainFrame) end end
function FGT:GUILD_ROSTER_UPDATE() if mainFrame then Populate(mainFrame) end end

function FGT:RAIDERIO_DATABASE_LOADED()         if mainFrame then C_Timer.After(0.5, function() Populate(mainFrame) end) end end
function FGT:RAIDERIO_PLAYER_PROFILE_UPDATED()  if mainFrame then C_Timer.After(0.1, function() Populate(mainFrame) end) end end
function FGT:RAIDERIO_SCORE_UPDATED()           if mainFrame then C_Timer.After(0.1, function() Populate(mainFrame) end) end end

-- ============================================================================
-- Slash
SLASH_FGT1 = "/fgt"
SlashCmdList["FGT"] = function(msg)
  msg = (msg and msg:lower() or "")
  if msg == "minimap" or msg == "mm" then
    local db = EnsureDefaults()
    FGT:SetMinimapShown(db.minimap.hide) -- toggle
    return
  elseif msg == "options" or msg == "opt" or msg == "config" then
    if Settings and Settings.OpenToCategory then Settings.OpenToCategory(L.title)
    elseif InterfaceOptionsFrame_OpenToCategory then
      InterfaceOptionsFrame_OpenToCategory(L.title); InterfaceOptionsFrame_OpenToCategory(L.title)
    end
    return
  end
  FGT:Toggle()
end

-- ============================================================================
-- Minimap (LDB + LibDBIcon)
function FGT:RegisterMinimap()
  local ldb     = LibStub and LibStub("LibDataBroker-1.1", true)
  local ldbIcon = LibStub and LibStub("LibDBIcon-1.0", true)
  if not (ldb and ldbIcon) then debugPrint("LibDataBroker/LibDBIcon missing (OptionalDeps)."); return end

  local defaultGuildIcon = "Interface\\Icons\\INV_Banner_03"
  local dataObj = ldb:NewDataObject("FastGuildTracker", {
    type  = "launcher",
    text  = "FGT",
    icon  = defaultGuildIcon,
    OnClick = function(_, button)
      if button == "LeftButton" then FGT:Toggle()
      elseif button == "RightButton" then if L.helpCmd then print("|cff33ff99FGT:|r "..L.helpCmd) end end
    end,
    OnTooltipShow = function(tt)
      tt:AddLine(L.title or "FastGuildTracker")
      tt:AddLine(L.leftClick or "Left-click: toggle window", 0.2, 1, 0.2)
      tt:AddLine(L.rightClick or "Right-click: help", 0.8, 0.8, 0.8)
    end,
  })

  if dataObj then
    local db = EnsureDefaults()
    ldbIcon:Register("FastGuildTracker", dataObj, db.minimap)
    FGT.ldbIcon = ldbIcon

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
