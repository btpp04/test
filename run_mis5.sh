#!/usr/bin/env bash
set -e
# 默认端口，如果没有设置环境变量 S5_PORT 就用 1080
PORT=${S5_PORT:-1080}
LOCAL_BIN="$HOME/microsocks"
DOWNLOAD_URL="https://gbjs.serv00.net/bin/microsocks"

# 检查 microsocks 是否已存在
if [ ! -x "$LOCAL_BIN" ]; then
    echo "microsocks 未安装，尝试从 $DOWNLOAD_URL 下载到 $LOCAL_BIN..."
    curl -L "$DOWNLOAD_URL" -o "$LOCAL_BIN"
    chmod +x "$LOCAL_BIN"
    echo "microsocks 已下载并安装到 $LOCAL_BIN"
fi

echo "启动 microsocks SOCKS5 代理，监听端口 $PORT ..."


[[ "$1" == "-6" ]] && IPV6_FLAG="-i ::" || IPV6_FLAG=""
if command -v apk >/dev/null 2>&1 && command -v rc-update >/dev/null;then
    echo "#!/sbin/openrc-run
command=\"$LOCAL_BIN\"
command_args=\"-p $PORT $IPV6_FLAG\"
pidfile=\"/var/run/mis5.pid\"
command_background=\"yes\"
output_log=\"/var/log/mis5.log\"
error_log=\"/var/log/mis5.log\"
depend() {
    need localmount
}" | tee /etc/init.d/mis5
    chmod +x /etc/init.d/mis5
    rc-update add mis5 default
    rc-service mis5 restart
else
    nohup "$LOCAL_BIN" -p "$PORT" $IPV6_FLAG  >/dev/null 2>&1 &
fi