clear
echo "   1. Cài đặt"
echo "   2. update config"

read -p "  Vui lòng chọn một số và nhấn Enter (Enter theo mặc định Cài đặt):  " num
[ -z "${num}" ] && num="1"




pre_install(){
ipv6_support=$(check_ipv6_support)
    listen_ip="0.0.0.0"
    if [ "$ipv6_support" -eq 1 ]; then
        listen_ip="::"
    fi
 clear
		read -p "Nhập số node cần cài và nhấn Enter (tối đa 2 node): " n
	 [ -z "${n}" ] && n="1"
    if [ "$n" -ge 2 ] ; then 
    n="2"
    fi
    a=0
  while [ $a -lt $n ]
do
 echo -e "node thứ $((a+1))"
 echo -e "[1] Vmess"
 echo -e "[2] Vless"
 echo -e "[3] trojan"
 echo -e "[4] Shadowsocks"
  read -p "chọn kiểu node(mặc định là Vmess):" NodeType
  if [ "$NodeType" == "1" ]; then
    NodeType="Vmess"
  elif [ "$NodeType" == "2" ]; then
    echo -e "[1] REALITY"
    echo -e "[2] TLS"
    echo -e "[3] PORT 80"
    read -p "chọn kiểu (mặc định là PORT 80):" cermode
    NodeType="Vless"
    if [ "$cermode" == "1" ]; then
        cermode = "none"
    elif [ "$cermode" == "2" ]; then
      cermode = "file"
    elif [ "$cermode" == "3" ]; then
      cermode = "none"
    else cermode = "none"
    fi
    
  elif [ "$NodeType" == "3" ]; then
    NodeType="Trojan"
  elif [ "$NodeType" == "4" ]; then
    NodeType="Shadowsocks"
  else
    NodeType="Vmess"
  fi
  echo "Bạn đã chọn $NodeType"
  echo "--------------------------------"


  #node id
    read -p " ID nút (Node_ID):" node_id
  [ -z "${node_id}" ] && node_id=0
  echo "-------------------------------"
  echo -e "Node_ID: ${node_id}"
  echo "-------------------------------"
  echo "Bạn đã chọn $NodeName"
  echo "--------------------------------"


  #node id
    read -p " ID nút (Node_ID):" node_id
  [ -z "${node_id}" ] && node_id=0
  echo "-------------------------------"
  echo -e "Node_ID: ${node_id}"
  echo "-------------------------------"

node_config=$(cat <<EOF
{
            "Core": "sing",
            "ApiHost": "https://4gthaga.com",
            "ApiKey": "4gthaga4gthaga4gthaga",
            "NodeID": $node_id,
            "NodeType": "$NodeType",
            "Timeout": 30,
            "ListenIP": "$listen_ip",
            "SendIP": "0.0.0.0",
            "DeviceOnlineMinTraffic": 100,
            "TCPFastOpen": true,
            "SniffEnabled": true,
            "EnableDNS": true,
            "CertConfig": {
                "CertMode": "$cermode",
                "RejectUnknownSni": false,
                "CertDomain": "example.cm",
                "CertFile": "/etc/V2bX/quoctai.crt",
                "KeyFile": "/etc/V2bX/quoctai.key",
                "Email": "v2bx@github.com",
                "Provider": "cloudflare",
                "DNSEnv": {
                    "EnvName": "env1"
                }
            }
        },
EOF

  
nodes_config+=("$node_config")
  


  a=$((a+1))
done
}

case "${num}" in
1) bash <(curl -Ls https://raw.githubusercontent.com/qtai2901/V2bX-script/master/install.sh)
openssl req -newkey rsa:2048 -x509 -sha256 -days 365 -nodes -out /etc/V2bX/quoctai.crt -keyout /etc/V2bX/quoctai.key -subj "/C=JP/ST=Tokyo/L=Chiyoda-ku/O=Google Trust Services LLC/CN=google.com"
nodes_config=()
pre_install
check_ipv6_support() {
    if ip -6 addr | grep -q "inet6"; then
        echo "1"  # 支持 IPv6
    else
        echo "0"  # 不支持 IPv6
    fi
}


nodes_config_str="${nodes_config[*]}"
formatted_nodes_config="${nodes_config_str%,}"

    # 创建 config.json 文件
    cat <<EOF > /etc/V2bX/config.json
{
    "Log": {
        "Level": "error",
        "Output": ""
    },
    "Cores": [
      {
          "Type": "sing",
          "Log": {
              "Level": "error",
              "Timestamp": true
          },
          "NTP": {
              "Enable": false,
              "Server": "time.apple.com",
              "ServerPort": 0
          },
          "OriginalPath": "/etc/V2bX/sing_origin.json"
      }],
    "Nodes": [$formatted_nodes_config]
}
EOF

cd /root
v2bx start
 ;;
 2) nodes_config=()
pre_install
check_ipv6_support() {
    if ip -6 addr | grep -q "inet6"; then
        echo "1"  # 支持 IPv6
    else
        echo "0"  # 不支持 IPv6
    fi
}


nodes_config_str="${nodes_config[*]}"
formatted_nodes_config="${nodes_config_str%,}"

    # 创建 config.json 文件
    cat <<EOF > /etc/V2bX/config.json
{
    "Log": {
        "Level": "error",
        "Output": ""
    },
    "Cores": [
      {
          "Type": "sing",
          "Log": {
              "Level": "error",
              "Timestamp": true
          },
          "NTP": {
              "Enable": false,
              "Server": "time.apple.com",
              "ServerPort": 0
          },
          "OriginalPath": "/etc/V2bX/sing_origin.json"
      }],
    "Nodes": [$formatted_nodes_config]
}
EOF

pre_install
cd /root
v2bx restart
 ;;

esac
