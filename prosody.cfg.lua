-- Основные настройки
pidfile = "/var/run/prosody/prosody.pid"
authentication = "internal_hashed"

-- Регистрация (открытая, потом отключите, когда создадите всех)
allow_registration = false
registration_invite_only = true

-- Слушаем все интерфейсы внутри контейнера
interfaces = { "0.0.0.0" }

-- Отключаем MAM (архивацию сообщений на сервере)
-- История только на клиентах!
storage = "internal"
modules_disabled = { "mam" }

-- Включаем нужные модули
modules_enabled = {
    "roster";
    "saslauth";
    "tls";
    "dialback";
    "disco";
    "carbons";
    "pep";
    "private";
    "blocklist";
    "vcard4";
    "vcard_legacy";
    "version";
    "uptime";
    "time";
    "ping";
    "register";
    "posix";
    "bosh";
    "websocket";
    "smacks";
    "csi_simple";
    "http_file_share";
    "invites";
    "invites_register";
}

-- SSL/TLS
c2s_require_encryption = true
s2s_require_encryption = true

-- Сертификаты (автоматически подставится onion-адрес)
https_certificate = "/etc/prosody/certs/host/<HOSTNAME>.crt"
https_key = "/etc/prosody/certs/host/<HOSTNAME>.key"

-- Виртуальный хост
VirtualHost "<HOSTNAME>"
    ssl = {
        certificate = "/etc/prosody/certs/host/<HOSTNAME>.crt";
        key = "/etc/prosody/certs/host/<HOSTNAME>.key";
    }

    disco_items = {
        { "u.<HOSTNAME>", "file sharing service" };
    }

    invites_page = "https://{host}:5281/invites_page?{invite.token}"

    caps_compat = true

-- Файлообменник (чтобы можно было отправлять файлы)
Component "u.<HOSTNAME>" "http_file_share"
    http_file_share_expires_after = 86400 -- 1 day
    http_file_share_global_quota = 2*1024*1024*1024 -- 2 GiB
    http_file_share_size_limit = 128*1024*1024 -- 128 MiB
