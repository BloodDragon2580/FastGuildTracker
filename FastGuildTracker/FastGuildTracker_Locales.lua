-- Centralized locales for all common WoW clients
-- Fallback: enUS

local LOCALE = GetLocale()

local Base = {
  -- Generic UI
  title        = "FastGuildTracker",
  desc         = "Options for FastGuildTracker",
  name_col     = "Name",
  runs_col     = "M+ Runs",
  rating_col   = "M+ Rating",
  best_col     = "Best Raid Kill",
  leftClick    = "Left-click: toggle window",
  rightClick   = "Right-click: help",
  helpCmd      = "Commands: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Show only online members",
  showMinimap  = "Show minimap icon",
  minimap_on   = "Minimap button |cff44ff44shown|r.",
  minimap_off  = "Minimap button |cffff4444hidden|r.",
  openOptions  = "Open options",

  -- Tooltip / Dungeons
  dungeons_header = "Recent / Best Dungeons:",
  no_rio_detail   = "No detailed dungeon runs from RaiderIO.",
  mplus_score     = "M+ Score",
  and_more        = "...and %d more",
}

local L = {}

-- English (default)
L.enUS = Base

-- German
L.deDE = {
  title        = "FastGuildTracker",
  desc         = "Optionen für FastGuildTracker",
  name_col     = "Name",
  runs_col     = "M+ Läufe",
  rating_col   = "M+ Wertung",
  best_col     = "Bester Raid-Kill",
  leftClick    = "Linksklick: Fenster ein-/ausblenden",
  rightClick   = "Rechtsklick: Hilfe",
  helpCmd      = "Befehle: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Nur Online-Mitglieder anzeigen",
  showMinimap  = "Minimap-Icon anzeigen",
  minimap_on   = "Minimap-Button |cff44ff44eingeblendet|r.",
  minimap_off  = "Minimap-Button |cffff4444ausgeblendet|r.",
  openOptions  = "Optionen öffnen",

  dungeons_header = "Aktuelle / Beste Dungeons:",
  no_rio_detail   = "Keine detaillierten Dungeonläufe von RaiderIO.",
  mplus_score     = "M+ Wertung",
  and_more        = "...und %d weitere",
}

-- French
L.frFR = {
  title        = "FastGuildTracker",
  desc         = "Options pour FastGuildTracker",
  name_col     = "Nom",
  runs_col     = "Donjons M+",
  rating_col   = "Score M+",
  best_col     = "Meilleur kill de raid",
  leftClick    = "Clic gauche : afficher/masquer la fenêtre",
  rightClick   = "Clic droit : aide",
  helpCmd      = "Commandes : /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Afficher uniquement les membres en ligne",
  showMinimap  = "Afficher l’icône de la minicarte",
  minimap_on   = "Bouton de minicarte |cff44ff44affiché|r.",
  minimap_off  = "Bouton de minicarte |cffff4444caché|r.",
  openOptions  = "Ouvrir les options",

  dungeons_header = "Donjons récents / meilleurs :",
  no_rio_detail   = "Aucune donnée détaillée de donjons depuis RaiderIO.",
  mplus_score     = "Score M+",
  and_more        = "...et %d de plus",
}

-- Spanish (EU)
L.esES = {
  title        = "FastGuildTracker",
  desc         = "Opciones de FastGuildTracker",
  name_col     = "Nombre",
  runs_col     = "Mazmorras M+",
  rating_col   = "Puntuación M+",
  best_col     = "Mejor jefe de banda",
  leftClick    = "Clic izquierdo: mostrar/ocultar ventana",
  rightClick   = "Clic derecho: ayuda",
  helpCmd      = "Comandos: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Mostrar solo miembros conectados",
  showMinimap  = "Mostrar icono del minimapa",
  minimap_on   = "Botón del minimapa |cff44ff44visible|r.",
  minimap_off  = "Botón del minimapa |cffff4444oculto|r.",
  openOptions  = "Abrir opciones",

  dungeons_header = "Mazmorras recientes / mejores:",
  no_rio_detail   = "No hay datos detallados de mazmorras de RaiderIO.",
  mplus_score     = "Puntuación M+",
  and_more        = "...y %d más",
}

-- Spanish (LA)
L.esMX = {
  title        = "FastGuildTracker",
  desc         = "Opciones de FastGuildTracker",
  name_col     = "Nombre",
  runs_col     = "Mazmorras M+",
  rating_col   = "Puntuación M+",
  best_col     = "Mejor jefe de banda",
  leftClick    = "Clic izq.: mostrar/ocultar ventana",
  rightClick   = "Clic der.: ayuda",
  helpCmd      = "Comandos: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Mostrar solo miembros en línea",
  showMinimap  = "Mostrar ícono del minimapa",
  minimap_on   = "Botón del minimapa |cff44ff44visible|r.",
  minimap_off  = "Botón del minimapa |cffff4444oculto|r.",
  openOptions  = "Abrir opciones",

  dungeons_header = "Mazmorras recientes / mejores:",
  no_rio_detail   = "No hay datos detallados de mazmorras de RaiderIO.",
  mplus_score     = "Puntuación M+",
  and_more        = "...y %d más",
}

-- Portuguese (BR)
L.ptBR = {
  title        = "FastGuildTracker",
  desc         = "Opções do FastGuildTracker",
  name_col     = "Nome",
  runs_col     = "Masmorras M+",
  rating_col   = "Índice M+",
  best_col     = "Melhor chefe de raide",
  leftClick    = "Clique esq.: mostrar/ocultar janela",
  rightClick   = "Clique dir.: ajuda",
  helpCmd      = "Comandos: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Mostrar apenas membros online",
  showMinimap  = "Exibir ícone do minimapa",
  minimap_on   = "Botão do minimapa |cff44ff44visível|r.",
  minimap_off  = "Botão do minimapa |cffff4444oculto|r.",
  openOptions  = "Abrir opções",

  dungeons_header = "Masmorras recentes / melhores:",
  no_rio_detail   = "Sem dados detalhados de masmorras do RaiderIO.",
  mplus_score     = "Índice M+",
  and_more        = "...e mais %d",
}

-- Italian
L.itIT = {
  title        = "FastGuildTracker",
  desc         = "Opzioni di FastGuildTracker",
  name_col     = "Nome",
  runs_col     = "Spedizioni M+",
  rating_col   = "Punteggio M+",
  best_col     = "Miglior uccisione raid",
  leftClick    = "Clic sin.: mostra/nascondi finestra",
  rightClick   = "Clic dest.: aiuto",
  helpCmd      = "Comandi: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Mostra solo i membri online",
  showMinimap  = "Mostra l'icona sulla minimappa",
  minimap_on   = "Pulsante della minimappa |cff44ff44visibile|r.",
  minimap_off  = "Pulsante della minimappa |cffff4444nascosto|r.",
  openOptions  = "Apri opzioni",

  dungeons_header = "Spedizioni recenti / migliori:",
  no_rio_detail   = "Nessun dettaglio delle spedizioni da RaiderIO.",
  mplus_score     = "Punteggio M+",
  and_more        = "...e altri %d",
}

-- Russian
L.ruRU = {
  title        = "FastGuildTracker",
  desc         = "Настройки FastGuildTracker",
  name_col     = "Имя",
  runs_col     = "Ключи M+",
  rating_col   = "Рейтинг M+",
  best_col     = "Лучший босс рейда",
  leftClick    = "ЛКМ: показать/скрыть окно",
  rightClick   = "ПКМ: помощь",
  helpCmd      = "Команды: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Показывать только онлайн-участников",
  showMinimap  = "Показывать значок на миникарте",
  minimap_on   = "Кнопка миникарты |cff44ff44включена|r.",
  minimap_off  = "Кнопка миникарты |cffff4444выключена|r.",
  openOptions  = "Открыть настройки",

  dungeons_header = "Недавние / лучшие подземелья:",
  no_rio_detail   = "Нет подробных данных по подземельям из RaiderIO.",
  mplus_score     = "Рейтинг M+",
  and_more        = "...и ещё %d",
}

-- Korean
L.koKR = {
  title        = "FastGuildTracker",
  desc         = "FastGuildTracker 설정",
  name_col     = "이름",
  runs_col     = "M+ 던전",
  rating_col   = "M+ 점수",
  best_col     = "최고 레이드 처치",
  leftClick    = "좌클릭: 창 토글",
  rightClick   = "우클릭: 도움말",
  helpCmd      = "명령어: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "온라인 길드원만 표시",
  showMinimap  = "미니맵 아이콘 표시",
  minimap_on   = "미니맵 버튼 |cff44ff44표시됨|r.",
  minimap_off  = "미니맵 버튼 |cffff4444숨김|r.",
  openOptions  = "옵션 열기",

  dungeons_header = "최근 / 최고 던전:",
  no_rio_detail   = "RaiderIO의 상세 던전 정보가 없습니다.",
  mplus_score     = "M+ 점수",
  and_more        = "...그리고 %d개 더",
}

-- Chinese (Simplified)
L.zhCN = {
  title        = "FastGuildTracker",
  desc         = "FastGuildTracker 选项",
  name_col     = "名字",
  runs_col     = "大秘境次数",
  rating_col   = "大秘境分数",
  best_col     = "最佳团队首领",
  leftClick    = "左键：打开/关闭窗口",
  rightClick   = "右键：帮助",
  helpCmd      = "命令：/fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "仅显示在线成员",
  showMinimap  = "显示小地图图标",
  minimap_on   = "小地图按钮 |cff44ff44已显示|r。",
  minimap_off  = "小地图按钮 |cffff4444已隐藏|r。",
  openOptions  = "打开选项",

  dungeons_header = "最近 / 最佳地下城：",
  no_rio_detail   = "没有来自 RaiderIO 的地下城详细数据。",
  mplus_score     = "大秘境分数",
  and_more        = "……以及另外 %d 个",
}

-- Chinese (Traditional)
L.zhTW = {
  title        = "FastGuildTracker",
  desc         = "FastGuildTracker 選項",
  name_col     = "名字",
  runs_col     = "大祕境次數",
  rating_col   = "大祕境分數",
  best_col     = "最佳團隊首領",
  leftClick    = "左鍵：開關視窗",
  rightClick   = "右鍵：說明",
  helpCmd      = "指令：/fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "只顯示上線成員",
  showMinimap  = "顯示小地圖圖示",
  minimap_on   = "小地圖按鈕 |cff44ff44已顯示|r。",
  minimap_off  = "小地圖按鈕 |cffff4444已隱藏|r。",
  openOptions  = "開啟選項",

  dungeons_header = "最近 / 最佳地城：",
  no_rio_detail   = "沒有來自 RaiderIO 的地城詳細資料。",
  mplus_score     = "大祕境分數",
  and_more        = "……以及另外 %d 個",
}

-- Select best match
local Dict = L[LOCALE] or Base

-- Safe fallback: any missing key returns English, then key
setmetatable(Dict, {
  __index = function(_, k)
    return (Base[k]) or k
  end
})

-- Expose
_G.FastGuildTrackerLocale = Dict
