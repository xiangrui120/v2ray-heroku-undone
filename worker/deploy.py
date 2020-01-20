import json
import os
import platform
import subprocess
from base64 import urlsafe_b64encode
from logging import basicConfig, getLogger
from random import randint
from secrets import token_urlsafe
from shutil import rmtree
from uuid import uuid4

import requests

assert os.getenv('AppName')

basicConfig(level=20)

LOGGER = getLogger('worker')
LOGGER_CONFIG = LOGGER.getChild('config')
LOGGER_COMMAND = LOGGER.getChild('command')
WORK_DIR = os.path.abspath(os.getcwd())
SETTINGS: dict = {
    'name': os.getenv('AppName'),
    'subscribe_path': os.getenv('Subscribe_Address', token_urlsafe(16)),
    'uuid': os.getenv('UUID', str(uuid4())),
    'port': randint(1000, 60000),
    'alter_id': os.getenv('AlterID', 16),
    'v2ray_path': os.getenv('V2_Path', f'/{token_urlsafe(8)}'),
    'reverse_proxy': os.getenv('Anti_Proxy_Path', 'https://www.baidu.com')
}


def execute(command: str, block: bool = True) -> int:
    LOGGER_COMMAND.info(f'Execute command "{command}"')
    if block:
        return subprocess.run(command, shell=True, check=True).returncode
    else:
        return subprocess.Popen(command, shell=True).returncode


def mkdir(dir: str):
    if os.path.exists(dir):
        rmtree(dir)
    os.mkdir(dir)


LOGGER_CONFIG.info('Start setting the system time zone')
execute(r"""rm -rf /etc/localtime \
            && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
            && date -R""")

LOGGER_CONFIG.info(
    f'The platform information is as follows: {platform.uname()}')
if platform.architecture()[0] == '32bit':
    SYS_BIT = 32
elif platform.architecture()[0] == '64bit':
    SYS_BIT = 64
else:
    raise RuntimeError(
        f'Unrecognized operating platform: {platform.architecture()}')

LOGGER_CONFIG.info('Start getting V2ray version list')
RELEASE_INFO = requests.get(
    'https://api.github.com/repos/v2ray/v2ray-core/releases/latest').json()
for perAsset in RELEASE_INFO['assets']:
    LOGGER_CONFIG.debug(f'Check asset {perAsset["name"]}')
    if perAsset['name'] == f'v2ray-linux-{SYS_BIT}.zip':
        DOWNLOAD_LINK = perAsset['browser_download_url']
        break
else:
    raise FileNotFoundError('No suitable version found')

LOGGER_CONFIG.info('Start downloading V2ray core files')
LOGGER_CONFIG.debug(f'Download link: {DOWNLOAD_LINK}')
with open(os.path.join(WORK_DIR, 'v2ray.zip'), 'wb') as f:
    f.write(requests.get(DOWNLOAD_LINK).content)

LOGGER_CONFIG.info('Start downloading Caddy files')
CADDY_URL = 'https://github.com/caddyserver/caddy/releases/download/v1.0.4/caddy_v1.0.4_linux_amd64.tar.gz' if (
    SYS_BIT == 64
) else 'https://github.com/caddyserver/caddy/releases/download/v1.0.4/caddy_v1.0.4_linux_386.tar.gz'
LOGGER_CONFIG.debug(f'Download link: {CADDY_URL}')
with open(os.path.join(WORK_DIR, 'caddy.tar.gz'), 'wb') as f:
    f.write(requests.get(CADDY_URL).content)

LOGGER_CONFIG.info('Extract the downloaded file')
mkdir('v2ray')
execute(
    f'unzip "{os.path.join(WORK_DIR,"v2ray.zip")}" -d "{os.path.join(WORK_DIR,"v2ray")}"'
)
mkdir('caddy')
execute(
    f'tar -xvf "{os.path.join(WORK_DIR,"caddy.tar.gz")}" -C "{os.path.join(WORK_DIR,"caddy")}"'
)

LOGGER_CONFIG.info('Start writing configuration files')
V2_CONF = {
    "log": {
        "loglevel": "warning"
    },
    "inbound": {
        "protocol": "vmess",
        "listen": "127.0.0.1",
        "port": SETTINGS['port'],
        "settings": {
            "clients": [{
                "id": SETTINGS['uuid'],
                "level": 1,
                "alterId": SETTINGS['alter_id']
            }]
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
                "path": SETTINGS['v2ray_path']
            }
        }
    },
    "outbound": {
        "protocol": "freedom",
        "settings": {}
    }
}
with open(os.path.join(WORK_DIR, './v2ray/config.json'),
          'wt',
          encoding='utf-8') as f:
    f.write(json.dumps(V2_CONF, indent=4, sort_keys=True))

SHARE_CONF = {
    "v": "2",
    "ps": f"{SETTINGS['name']}.herokuapp.com",
    "add": f"{SETTINGS['name']}.herokuapp.com",
    "port": "443",
    "id": SETTINGS['uuid'],
    "aid": SETTINGS['alter_id'],
    "net": "ws",
    "type": "none",
    "host": f"{SETTINGS['name']}.herokuapp.com",
    "path": SETTINGS['v2ray_path'],
    "tls": "tls"
}

V2_LINK = urlsafe_b64encode(json.dumps(SHARE_CONF).encode()).decode()
mkdir('subscribe')
with open(os.path.join(WORK_DIR, 'subscribe', 'index.html'),
          'wt',
          encoding='utf-8') as f:
    f.write(f'vmess://{V2_LINK}')

CADDY_CONF = f""":{os.getenv('PORT',80)} {{
    gzip
    log stdout
    timeouts none

    proxy / {SETTINGS['reverse_proxy']} {{
        except /{SETTINGS['subscribe_path']}
    }}

    proxy {SETTINGS['v2ray_path']} 127.0.0.1:{SETTINGS['port']} {{
        websocket
        header_upstream -Origin
    }}

}}
:{os.getenv('PORT',80)}/{SETTINGS['subscribe_path']} {{
    gzip
    log stdout
    root "{os.path.join(WORK_DIR,'subscribe')}"
}}"""
with open(os.path.join(WORK_DIR, './caddy/Caddyfile'), 'wt',
          encoding='utf-8') as f:
    f.write(CADDY_CONF)

LOGGER_CONFIG.info(f'The V2ray link is vmess://{V2_LINK}')