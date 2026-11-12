-- Translations: ["English text"] = { Turkish, Russian }
local TR = {
	-- Tabs
	["About"] = { "Hakkında", "О скрипте" },
	["Movement"] = { "Hareket", "Движение" },
	["ESP"] = { "ESP", "ESP" },
	["Misc"] = { "Çeşitli", "Разное" },
	["Settings"] = { "Ayarlar", "Настройки" },
	["Game"] = { "Oyun", "Игра" },

	-- Sections
	["Utility"] = { "Araçlar", "Утилиты" },
	["Players"] = { "Oyuncular", "Игроки" },
	["Server"] = { "Sunucu", "Сервер" },
	["Options"] = { "Seçenekler", "Опции" },
	["Menu"] = { "Menü", "Меню" },
	["Config"] = { "Yapılandırma", "Конфигурация" },
	["Info"] = { "Bilgi", "Информация" },
	["Language"] = { "Dil", "Язык" },
	["About SezarHub"] = { "SezarHub Hakkında", "О SezarHub" },
	["Details"] = { "Detaylar", "Детали" },
	["Links"] = { "Bağlantılar", "Ссылки" },

	-- Movement
	["Speed"] = { "Hız", "Скорость" },
	["Speed Value"] = { "Hız Değeri", "Значение скорости" },
	["CFrame Speed (alt)"] = { "CFrame Hızı (alternatif)", "CFrame скорость (альт.)" },
	["CFrame Speed Value"] = { "CFrame Hız Değeri", "Значение CFrame скорости" },
	["Jump"] = { "Zıplama", "Прыжок" },
	["Jump Value"] = { "Zıplama Değeri", "Значение прыжка" },
	["Infinite Jump"] = { "Sonsuz Zıplama", "Бесконечный прыжок" },
	["Fly"] = { "Uçma", "Полёт" },
	["Fly Speed"] = { "Uçuş Hızı", "Скорость полёта" },
	["Controls: WASD to move, Space = up, LeftShift = down"] = {
		"Kontroller: WASD hareket, Space = yukarı, LeftShift = aşağı",
		"Управление: WASD — движение, Space — вверх, LeftShift — вниз",
	},
	["Noclip"] = { "Duvardan Geçme", "Ноклип" },

	-- ESP
	["ESP Enabled"] = { "ESP Açık", "ESP включён" },
	["Names"] = { "İsimler", "Имена" },
	["Distance"] = { "Mesafe", "Дистанция" },
	["Health"] = { "Can", "Здоровье" },
	["Box"] = { "Kutu", "Рамка" },
	["Highlight (through walls)"] = { "Vurgu (duvar arkası)", "Подсветка (сквозь стены)" },
	["Hide Teammates"] = { "Takım Arkadaşlarını Gizle", "Скрыть союзников" },
	["Use Team Colors"] = { "Takım Renklerini Kullan", "Цвета команд" },
	["ESP Color"] = { "ESP Rengi", "Цвет ESP" },
	["Max Distance"] = { "Maks. Mesafe", "Макс. дистанция" },

	-- Misc
	["Anti-AFK"] = { "Anti-AFK", "Анти-АФК" },
	["Fullbright"] = { "Tam Parlaklık", "Полная яркость" },
	["Custom FOV"] = { "Özel FOV", "Свой FOV" },
	["FOV Value"] = { "FOV Değeri", "Значение FOV" },
	["Select Player"] = { "Oyuncu Seç", "Выбрать игрока" },
	["Teleport to Player"] = { "Oyuncuya Işınlan", "Телепорт к игроку" },
	["Spectate Player"] = { "Oyuncuyu İzle", "Наблюдать за игроком" },
	["Click Teleport (Ctrl + Click)"] = { "Tıkla Işınlan (Ctrl + Tık)", "Клик-телепорт (Ctrl + клик)" },
	["Rejoin"] = { "Yeniden Bağlan", "Перезайти" },
	["Server Hop"] = { "Sunucu Değiştir", "Смена сервера" },

	-- Notifications
	["enabled"] = { "açıldı", "включено" },
	["disabled"] = { "kapatıldı", "выключено" },
	["Feature active"] = { "Özellik aktif", "Функция активна" },
	["Feature inactive"] = { "Özellik pasif", "Функция неактивна" },
	["Value updated"] = { "Değer güncellendi", "Значение обновлено" },
	["Selected"] = { "Seçildi", "Выбрано" },
	["Keybind set"] = { "Tuş atandı", "Клавиша назначена" },
	["Menu hidden"] = { "Menü gizlendi", "Меню скрыто" },
	["Key"] = { "Tuş", "Клавиша" },
	["Error"] = { "Hata", "Ошибка" },
	["Teleported"] = { "Işınlandı", "Телепортирован" },
	["Teleport failed"] = { "Işınlanma başarısız", "Ошибка телепорта" },
	["Select a valid player first"] = { "Önce geçerli bir oyuncu seç", "Сначала выберите игрока" },
	["Spectate failed"] = { "İzleme başarısız", "Ошибка наблюдения" },
	["Searching for a server..."] = { "Sunucu aranıyor...", "Поиск сервера..." },
	["Server Hop failed"] = { "Sunucu değişimi başarısız", "Смена сервера не удалась" },
	["Could not fetch server list"] = { "Sunucu listesi alınamadı", "Не удалось получить список серверов" },
	["No free server found"] = { "Boş sunucu bulunamadı", "Свободный сервер не найден" },

	-- Settings
	["Menu Key"] = { "Menü Tuşu", "Клавиша меню" },
	["Config saving: supported"] = { "Ayar kaydı: destekleniyor", "Сохранение: поддерживается" },
	["Config saving: not supported by this executor"] = {
		"Ayar kaydı: bu executor desteklemiyor", "Сохранение: не поддерживается этим executor",
	},
	["Auto Save"] = { "Otomatik Kaydet", "Автосохранение" },
	["Save Config Now"] = { "Ayarları Şimdi Kaydet", "Сохранить сейчас" },
	["Load Config"] = { "Ayarları Yükle", "Загрузить настройки" },
	["Copy PlaceId"] = { "PlaceId Kopyala", "Копировать PlaceId" },
	["Unload Hub"] = { "Hub'ı Kapat", "Выгрузить хаб" },
	["Config saved"] = { "Ayarlar kaydedildi", "Настройки сохранены" },
	["Settings written to file"] = { "Ayarlar dosyaya yazıldı", "Записано в файл" },
	["Save failed"] = { "Kaydetme başarısız", "Ошибка сохранения" },
	["Executor may not support files"] = { "Executor dosya desteklemiyor olabilir", "Executor может не поддерживать файлы" },
	["Config loaded"] = { "Ayarlar yüklendi", "Настройки загружены" },
	["Settings restored"] = { "Ayarlar geri yüklendi", "Настройки восстановлены" },
	["Load failed"] = { "Yükleme başarısız", "Ошибка загрузки" },
	["No saved config found"] = { "Kayıtlı ayar bulunamadı", "Сохранённых настроек нет" },
	["Copied"] = { "Kopyalandı", "Скопировано" },
	["Not supported"] = { "Desteklenmiyor", "Не поддерживается" },
	["Executor has no setclipboard"] = { "Executor setclipboard desteklemiyor", "Нет поддержки setclipboard" },
	["SezarHub loaded"] = { "SezarHub yüklendi", "SezarHub загружен" },
	["Config restored"] = { "Kayıtlı ayarlar yüklendi", "Сохранённые настройки загружены" },
	["Welcome"] = { "Hoş geldin", "Добро пожаловать" },

	-- Splash + About
	["WELCOME"] = { "HOŞ GELDİN", "ДОБРО ПОЖАЛОВАТЬ" },
	["Developer"] = { "Geliştirici", "Разработчик" },
	["Version"] = { "Sürüm", "Версия" },
	["Last Update"] = { "Son Güncelleme", "Последнее обновление" },
	["Executor"] = { "Executor", "Executor" },
	["Player"] = { "Oyuncu", "Игрок" },
	["Local Time"] = { "Yerel Saat", "Местное время" },
	["Date"] = { "Tarih", "Дата" },
	["Session Time"] = { "Oturum Süresi", "Время сессии" },
	["Discord"] = { "Discord", "Discord" },
	["Copy Discord Link"] = { "Discord Linkini Kopyala", "Скопировать ссылку Discord" },
	["SezarHub is a free multi-game script hub made for the community. Stay active on our Discord for giveaways and updates."] = {
		"SezarHub, topluluk için hazırlanmış ücretsiz çok oyunlu bir script hub'ıdır. Çekilişler ve güncellemeler için Discord'umuzda aktif kal.",
		"SezarHub — бесплатный мультиигровой скрипт-хаб для сообщества. Будьте активны в нашем Discord ради розыгрышей и обновлений.",
	},
}

local TURKISH, RUSSIAN = "Türkçe", "Русский"
local Dict = { [TURKISH] = {}, [RUSSIAN] = {} }
for k, v in pairs(TR) do
	Dict[TURKISH][k] = v[1]
	Dict[RUSSIAN][k] = v[2]
end

return { Names = { "English", TURKISH, RUSSIAN }, Dict = Dict }
