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

  -- New: Debug
  debug_label  = "Enable debug logging",
  debug_on     = "Debug logging |cff44ff44enabled|r.",
  debug_off    = "Debug logging |cffff4444disabled|r.",

  -- Tooltip / Dungeons
  dungeons_header = "Recent / Best Dungeons:",
  no_rio_detail   = "No detailed dungeon runs from RaiderIO.",
  mplus_score     = "M+ Score",
  and_more        = "...and %d more",

  -- Debug messages
  debug_event            = "[DEBUG] Event:",
  debug_no_rio           = "[DEBUG] RaiderIO not loaded",
  debug_profile_ok       = "[DEBUG] Profile OK:",
  debug_profile_missing  = "[DEBUG] Profile missing for:",
  debug_profile_nil_name = "[DEBUG] fullName is empty",
  debug_fullname         = "[DEBUG] fullName:",
  debug_populate_rows    = "[DEBUG] Populate: 0 rows (no guild data/RIO)",
  debug_tooltip_no_rio   = "[DEBUG] Tooltip: no RIO detail",

  -- Region DB (auto region EU/US/KR/TW)
  db_status_title   = "Raider.IO Region Database",
  db_status_ok      = "Region DB loaded",
  db_status_missing = "Region DB missing: %s",
  db_load_now       = "Load Region DB now",
  db_loaded         = "Database loaded.",
  db_load_failed    = "DB load failed",
  db_warn_chat      = "Raider.IO DB not loaded. Scores may be missing. Open options or type /fgt loaddb.",
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

  -- Debug
  debug_label  = "Debug-Logging aktivieren",
  debug_on     = "Debug-Logging |cff44ff44aktiv|r.",
  debug_off    = "Debug-Logging |cffff4444deaktiviert|r.",

  -- Tooltip / Dungeons
  dungeons_header = "Aktuelle / Beste Dungeons:",
  no_rio_detail   = "Keine detaillierten Dungeonläufe von RaiderIO.",
  mplus_score     = "M+ Wertung",
  and_more        = "...und %d weitere",

  -- Debug messages
  debug_event            = "[DEBUG] Ereignis:",
  debug_no_rio           = "[DEBUG] RaiderIO nicht geladen",
  debug_profile_ok       = "[DEBUG] Profil OK:",
  debug_profile_missing  = "[DEBUG] Profil fehlt für:",
  debug_profile_nil_name = "[DEBUG] fullName ist leer",
  debug_fullname         = "[DEBUG] fullName:",
  debug_populate_rows    = "[DEBUG] Populate: 0 Zeilen (keine Gildendaten/RIO)",
  debug_tooltip_no_rio   = "[DEBUG] Tooltip: keine RIO-Details",

  -- Region DB
  db_status_title   = "Raider.IO Regions-Datenbank",
  db_status_ok      = "Regions-DB geladen",
  db_status_missing = "Regions-DB fehlt: %s",
  db_load_now       = "Regions-DB jetzt laden",
  db_loaded         = "Datenbank geladen.",
  db_load_failed    = "DB konnte nicht geladen werden",
  db_warn_chat      = "Raider.IO DB nicht geladen. Wertungen könnten fehlen. Öffne die Optionen oder nutze /fgt loaddb.",
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

  -- Debug
  debug_label  = "Activer le journal de débogage",
  debug_on     = "Journal de débogage |cff44ff44activé|r.",
  debug_off    = "Journal de débogage |cffff4444désactivé|r.",

  dungeons_header = "Donjons récents / meilleurs :",
  no_rio_detail   = "Aucune donnée détaillée de donjons depuis RaiderIO.",
  mplus_score     = "Score M+",
  and_more        = "...et %d de plus",

  -- Debug messages
  debug_event            = "[DEBUG] Évènement :",
  debug_no_rio           = "[DEBUG] RaiderIO non chargé",
  debug_profile_ok       = "[DEBUG] Profil OK :",
  debug_profile_missing  = "[DEBUG] Profil manquant pour :",
  debug_profile_nil_name = "[DEBUG] fullName est vide",
  debug_fullname         = "[DEBUG] fullName :",
  debug_populate_rows    = "[DEBUG] Populate : 0 lignes (pas de données de guilde/RIO)",
  debug_tooltip_no_rio   = "[DEBUG] Tooltip : pas de détails RIO",

  -- Region DB
  db_status_title   = "Base de données régionale Raider.IO",
  db_status_ok      = "Base régionale chargée",
  db_status_missing = "Base régionale manquante : %s",
  db_load_now       = "Charger la base régionale",
  db_loaded         = "Base de données chargée.",
  db_load_failed    = "Échec du chargement de la base",
  db_warn_chat      = "Base de données Raider.IO non chargée. Des scores peuvent manquer. Ouvrez les options ou tapez /fgt loaddb.",
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

  -- Debug
  debug_label  = "Activar registro de depuración",
  debug_on     = "Depuración |cff44ff44activada|r.",
  debug_off    = "Depuración |cffff4444desactivada|r.",

  dungeons_header = "Mazmorras recientes / mejores:",
  no_rio_detail   = "No hay datos detallados de mazmorras de RaiderIO.",
  mplus_score     = "Puntuación M+",
  and_more        = "...y %d más",

  -- Debug messages
  debug_event            = "[DEBUG] Evento:",
  debug_no_rio           = "[DEBUG] RaiderIO no cargado",
  debug_profile_ok       = "[DEBUG] Perfil OK:",
  debug_profile_missing  = "[DEBUG] Falta perfil para:",
  debug_profile_nil_name = "[DEBUG] fullName está vacío",
  debug_fullname         = "[DEBUG] fullName:",
  debug_populate_rows    = "[DEBUG] Populate: 0 filas (sin datos de hermandad/RIO)",
  debug_tooltip_no_rio   = "[DEBUG] Tooltip: sin detalles de RIO",

  -- Region DB
  db_status_title   = "Base de datos regional de Raider.IO",
  db_status_ok      = "BD regional cargada",
  db_status_missing = "Falta BD regional: %s",
  db_load_now       = "Cargar BD regional",
  db_loaded         = "Base de datos cargada.",
  db_load_failed    = "Error al cargar la BD",
  db_warn_chat      = "BD de Raider.IO no cargada. Pueden faltar puntuaciones. Abre opciones o escribe /fgt loaddb.",
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

  -- Debug
  debug_label  = "Activar registro de depuración",
  debug_on     = "Depuración |cff44ff44activada|r.",
  debug_off    = "Depuración |cffff4444desactivada|r.",

  dungeons_header = "Mazmorras recientes / mejores:",
  no_rio_detail   = "No hay datos detallados de mazmorras de RaiderIO.",
  mplus_score     = "Puntuación M+",
  and_more        = "...y %d más",

  -- Debug messages
  debug_event            = "[DEBUG] Evento:",
  debug_no_rio           = "[DEBUG] RaiderIO no cargado",
  debug_profile_ok       = "[DEBUG] Perfil OK:",
  debug_profile_missing  = "[DEBUG] Falta perfil para:",
  debug_profile_nil_name = "[DEBUG] fullName está vacío",
  debug_fullname         = "[DEBUG] fullName:",
  debug_populate_rows    = "[DEBUG] Populate: 0 filas (sin datos de hermandad/RIO)",
  debug_tooltip_no_rio   = "[DEBUG] Tooltip: sin detalles de RIO",

  -- Region DB
  db_status_title   = "Base de datos regional de Raider.IO",
  db_status_ok      = "BD regional cargada",
  db_status_missing = "Falta BD regional: %s",
  db_load_now       = "Cargar BD regional",
  db_loaded         = "Base de datos cargada.",
  db_load_failed    = "Error al cargar la BD",
  db_warn_chat      = "BD de Raider.IO no cargada. Pueden faltar puntuaciones. Abre opciones o usa /fgt loaddb.",
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

  -- Debug
  debug_label  = "Ativar logging de depuração",
  debug_on     = "Depuração |cff44ff44ativada|r.",
  debug_off    = "Depuração |cffff4444desativada|r.",

  dungeons_header = "Masmorras recentes / melhores:",
  no_rio_detail   = "Sem dados detalhados de masmorras do RaiderIO.",
  mplus_score     = "Índice M+",
  and_more        = "...e mais %d",

  -- Debug messages
  debug_event            = "[DEBUG] Evento:",
  debug_no_rio           = "[DEBUG] RaiderIO não carregado",
  debug_profile_ok       = "[DEBUG] Perfil OK:",
  debug_profile_missing  = "[DEBUG] Perfil ausente para:",
  debug_profile_nil_name = "[DEBUG] fullName está vazio",
  debug_fullname         = "[DEBUG] fullName:",
  debug_populate_rows    = "[DEBUG] Populate: 0 linhas (sem dados da guilda/RIO)",
  debug_tooltip_no_rio   = "[DEBUG] Tooltip: sem detalhes do RIO",

  -- Region DB
  db_status_title   = "Banco de dados regional do Raider.IO",
  db_status_ok      = "BD regional carregado",
  db_status_missing = "BD regional ausente: %s",
  db_load_now       = "Carregar BD regional",
  db_loaded         = "Banco de dados carregado.",
  db_load_failed    = "Falha ao carregar o BD",
  db_warn_chat      = "BD do Raider.IO não carregado. Pontuações podem faltar. Abra as opções ou digite /fgt loaddb.",
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

  -- Debug
  debug_label  = "Abilita logging di debug",
  debug_on     = "Debug |cff44ff44abilitato|r.",
  debug_off    = "Debug |cffff4444disabilitato|r.",

  dungeons_header = "Spedizioni recenti / migliori:",
  no_rio_detail   = "Nessun dettaglio delle spedizioni da RaiderIO.",
  mplus_score     = "Punteggio M+",
  and_more        = "...e altri %d",

  -- Debug messages
  debug_event            = "[DEBUG] Evento:",
  debug_no_rio           = "[DEBUG] RaiderIO non caricato",
  debug_profile_ok       = "[DEBUG] Profilo OK:",
  debug_profile_missing  = "[DEBUG] Profilo mancante per:",
  debug_profile_nil_name = "[DEBUG] fullName è vuoto",
  debug_fullname         = "[DEBUG] fullName:",
  debug_populate_rows    = "[DEBUG] Populate: 0 righe (nessun dato gilda/RIO)",
  debug_tooltip_no_rio   = "[DEBUG] Tooltip: nessun dettaglio RIO",

  -- Region DB
  db_status_title   = "Database regionale Raider.IO",
  db_status_ok      = "Database regionale caricato",
  db_status_missing = "Database regionale mancante: %s",
  db_load_now       = "Carica database regionale",
  db_loaded         = "Database caricato.",
  db_load_failed    = "Caricamento del database fallito",
  db_warn_chat      = "Database Raider.IO non caricato. I punteggi potrebbero mancare. Apri le opzioni o usa /fgt loaddb.",
}

-- Russian
L.ruRU = {
  title        = "FastGuildTracker",
  desc         = "Настройки FastGuildTracker",
  name_col     = "Имя",
  runs_col     = "Ключи M+",
  rating_col   = "Рейтинг M+",
  best_col     = "Лучшее убийство в рейде",
  leftClick    = "ЛКМ: показать/скрыть окно",
  rightClick   = "ПКМ: помощь",
  helpCmd      = "Команды: /fgt  |  /fgt options  |  /fgt minimap",
  onlyOnline   = "Показывать только тех, кто сейчас в сети",
  showMinimap  = "Показывать значок на миникарте",
  minimap_on   = "Кнопка миникарты |cff44ff44включена|r.",
  minimap_off  = "Кнопка миникарты |cffff4444выключена|r.",
  openOptions  = "Открыть настройки",

  -- Debug
  debug_label  = "Включить отладочный лог",
  debug_on     = "Отладка |cff44ff44включена|r.",
  debug_off    = "Отладка |cffff4444выключена|r.",

  dungeons_header = "Недавние / лучшие подземелья:",
  no_rio_detail   = "Нет подробных данных по подземельям из RaiderIO.",
  mplus_score     = "Рейтинг M+",
  and_more        = "...и ещё %d",

  -- Debug messages
  debug_event            = "[DEBUG] Событие:",
  debug_no_rio           = "[DEBUG] RaiderIO не загружен",
  debug_profile_ok       = "[DEBUG] Профиль OK:",
  debug_profile_missing  = "[DEBUG] Профиль отсутствует для:",
  debug_profile_nil_name = "[DEBUG] fullName пуст",
  debug_fullname         = "[DEBUG] fullName:",
  debug_populate_rows    = "[DEBUG] Заполнение: 0 строк (нет данных гильдии/RIO)",
  debug_tooltip_no_rio   = "[DEBUG] Подсказка: нет деталей RIO",

  -- Region DB
  db_status_title   = "Региональная база данных Raider.IO",
  db_status_ok      = "Региональная БД загружена",
  db_status_missing = "Отсутствует региональная БД: %s",
  db_load_now       = "Загрузить региональную БД",
  db_loaded         = "База данных загружена.",
  db_load_failed    = "Не удалось загрузить БД",
  db_warn_chat      = "База данных Raider.IO не загружена. Рейтинги могут отсутствовать. Откройте настройки или введите /fgt loaddb.",
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

  -- Debug
  debug_label  = "디버그 로깅 활성화",
  debug_on     = "디버그 로깅 |cff44ff44활성화|r.",
  debug_off    = "디버그 로깅 |cffff4444비활성화|r.",

  dungeons_header = "최근 / 최고 던전:",
  no_rio_detail   = "RaiderIO의 상세 던전 정보가 없습니다.",
  mplus_score     = "M+ 점수",
  and_more        = "...그리고 %d개 더",

  -- Debug messages
  debug_event            = "[DEBUG] 이벤트:",
  debug_no_rio           = "[DEBUG] RaiderIO 로드되지 않음",
  debug_profile_ok       = "[DEBUG] 프로필 OK:",
  debug_profile_missing  = "[DEBUG] 프로필 없음:",
  debug_profile_nil_name = "[DEBUG] fullName 비어 있음",
  debug_fullname         = "[DEBUG] fullName:",
  debug_populate_rows    = "[DEBUG] Populate: 0개 행 (길드 데이터/RIO 없음)",
  debug_tooltip_no_rio   = "[DEBUG] 툴팁: RIO 상세 없음",

  -- Region DB
  db_status_title   = "Raider.IO 지역 데이터베이스",
  db_status_ok      = "지역 DB 로드됨",
  db_status_missing = "지역 DB 누락: %s",
  db_load_now       = "지역 DB 로드",
  db_loaded         = "데이터베이스 로드 완료.",
  db_load_failed    = "DB 로드 실패",
  db_warn_chat      = "Raider.IO DB가 로드되지 않았습니다. 점수가 표시되지 않을 수 있습니다. 옵션을 열거나 /fgt loaddb 를 사용하세요.",
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

  -- Debug
  debug_label  = "启用调试日志",
  debug_on     = "调试日志 |cff44ff44已启用|r。",
  debug_off    = "调试日志 |cffff4444已禁用|r。",

  dungeons_header = "最近 / 最佳地下城：",
  no_rio_detail   = "没有来自 RaiderIO 的地下城详细数据。",
  mplus_score     = "大秘境分数",
  and_more        = "……以及另外 %d 个",

  -- Debug messages
  debug_event            = "[DEBUG] 事件：",
  debug_no_rio           = "[DEBUG] 未加载 RaiderIO",
  debug_profile_ok       = "[DEBUG] 角色档案 OK：",
  debug_profile_missing  = "[DEBUG] 缺少角色档案：",
  debug_profile_nil_name = "[DEBUG] fullName 为空",
  debug_fullname         = "[DEBUG] fullName：",
  debug_populate_rows    = "[DEBUG] Populate：0 行（无公会数据/RIO）",
  debug_tooltip_no_rio   = "[DEBUG] 工具提示：无 RIO 详细信息",

  -- Region DB
  db_status_title   = "Raider.IO 区域数据库",
  db_status_ok      = "区域数据库已加载",
  db_status_missing = "缺少区域数据库：%s",
  db_load_now       = "现在加载区域数据库",
  db_loaded         = "数据库已加载。",
  db_load_failed    = "数据库加载失败",
  db_warn_chat      = "未加载 Raider.IO 数据库。可能缺少分数。请打开选项或输入 /fgt loaddb。",
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

  -- Debug
  debug_label  = "啟用除錯記錄",
  debug_on     = "除錯記錄 |cff44ff44已啟用|r。",
  debug_off    = "除錯記錄 |cffff4444已停用|r。",

  dungeons_header = "最近 / 最佳地城：",
  no_rio_detail   = "沒有來自 RaiderIO 的地城詳細資料。",
  mplus_score     = "大祕境分數",
  and_more        = "……以及另外 %d 個",

  -- Debug messages
  debug_event            = "[DEBUG] 事件：",
  debug_no_rio           = "[DEBUG] 未載入 RaiderIO",
  debug_profile_ok       = "[DEBUG] 個人檔 OK：",
  debug_profile_missing  = "[DEBUG] 缺少個人檔：",
  debug_profile_nil_name = "[DEBUG] fullName 為空",
  debug_fullname         = "[DEBUG] fullName：",
  debug_populate_rows    = "[DEBUG] Populate：0 行（無公會資料/RIO）",
  debug_tooltip_no_rio   = "[DEBUG] 工具提示：沒有 RIO 詳細資訊",

  -- Region DB
  db_status_title   = "Raider.IO 區域資料庫",
  db_status_ok      = "區域資料庫已載入",
  db_status_missing = "缺少區域資料庫：%s",
  db_load_now       = "立即載入區域資料庫",
  db_loaded         = "資料庫已載入。",
  db_load_failed    = "資料庫載入失敗",
  db_warn_chat      = "未載入 Raider.IO 資料庫。可能缺少分數。請開啟選項或輸入 /fgt loaddb。",
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
