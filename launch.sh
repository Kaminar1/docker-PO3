#!/bin/bash

set -x

SERVER_VERSION=PO3-3.4.11F
cd /data

if ! [[ "$EULA" = "false" ]]; then
	echo "eula=true" > eula.txt
else
	echo "You must accept the EULA to install."
	exit 99
fi

if ! [[ -f "Server-Files-$SERVER_VERSION.zip" ]]; then
	rm -fr config defaultconfigs kubejs mods packmenu Simple.zip forge*
	curl -Lo "Server-Files-$SERVER_VERSION.zip" 'https://edge.forgecdn.net/files/4345/112/PO3%20-%203.4.11Fserver.zip' || exit 9
	unzip -u -o "Server-Files-$SERVER_VERSION.zip" -d /data
	DIR_TEST=$(find . -type d -maxdepth 1 | tail -1 | sed 's/^.\{2\}//g')
	if [[ $(find . -type d -maxdepth 1 | wc -l) -gt 1 ]]; then
		cd "${DIR_TEST}"
		find . -type d -exec chmod 777 {} +
		mv -f * /data
		cd /data
		rm -fr "$DIR_TEST"
	fi
fi

if [ ! -f server.properties ]; then
cat << 'EOF' > server.properties
server-port=25565
allow-flight=false
online-mode=true
white-list=false
max-players=20
motd=A Minecraft Server
EOF
fi

if [[ -n "$MOTD" ]]; then
    sed -i "s/^motd=.*/motd=$MOTD/" /data/server.properties
fi
if [[ -n "$ENABLE_WHITELIST" ]]; then
    sed -i "s/white-list=.*/white-list=$ENABLE_WHITELIST/" /data/server.properties
fi
if [[ -n "$ALLOW_FLIGHT" ]]; then
    sed -i "s/allow-flight=.*/allow-flight=$ALLOW_FLIGHT/" /data/server.properties
fi
if [[ -n "$MAX_PLAYERS" ]]; then
    sed -i "s/max-players=.*/max-players=$MAX_PLAYERS/" /data/server.properties
fi
if [[ -n "$ONLINE_MODE" ]]; then
    sed -i "s/online-mode=.*/online-mode=$ONLINE_MODE/" /data/server.properties
fi
echo "[]" > whitelist.json
IFS=',' read -ra USERS <<< "$WHITELIST_USERS"
for raw_username in "${USERS[@]}"; do
	username=$(echo "$raw_username" | xargs)
	if [[ ! "$username" =~ ^[a-zA-Z0-9_]{3,16}$ ]]; then
		echo "Whitelist: Invalid username: '$username'. Skipping..."
		continue
	fi

	UUID=$(curl -s "https://api.mojang.com/users/profiles/minecraft/$username" | jq -r '.id')
	if [[ "$UUID" != "null" ]]; then
		if jq -e ".[] | select(.uuid == \"$UUID\")" whitelist.json > /dev/null; then
			echo "Whitelist: $username ($UUID) is already whitelisted."
		else
			UUID=$(echo "$UUID" | sed -r 's/(.{8})(.{4})(.{4})(.{4})(.{12})/\1-\2-\3-\4-\5/')
			echo "Whitelist: Adding $username ($UUID) to whitelist."
			jq ". += [{\"uuid\": \"$UUID\", \"name\": \"$username\"}]" whitelist.json > tmp.json && mv tmp.json whitelist.json
		fi
	else
		echo "Whitelist: Failed to fetch UUID for $username."
	fi
done
echo "[]" > ops.json
IFS=',' read -ra OPS <<< "$OP_USERS"
for raw_username in "${OPS[@]}"; do
    username=$(echo "$raw_username" | xargs)
    if [[ ! "$username" =~ ^[a-zA-Z0-9_]{3,16}$ ]]; then
        echo "Ops: Invalid username: '$username'. Skipping..."
        continue
    fi

    UUID=$(curl -s "https://api.mojang.com/users/profiles/minecraft/$username" | jq -r '.id')
    if [[ "$UUID" != "null" ]]; then
        if jq -e ".[] | select(.uuid == \"$UUID\")" ops.json > /dev/null; then
            echo "Ops: $username ($UUID) is already an operator."
        else
			UUID=$(echo "$UUID" | sed -r 's/(.{8})(.{4})(.{4})(.{4})(.{12})/\1-\2-\3-\4-\5/')
            echo "Ops: Adding $username ($UUID) as operator."
            jq ". += [{\"uuid\": \"$UUID\", \"name\": \"$username\", \"level\": 4, \"bypassesPlayerLimit\": false}]" ops.json > tmp.json && mv tmp.json ops.json
        fi
    else
        echo "Ops: Failed to fetch UUID for $username."
    fi
done

sed -i 's/server-port.*/server-port=25565/g' server.properties

cat << 'EOF' > run.sh
#!/bin/bash
echo "Starting Forge server with options: ${JVM_OPTS:-"-Xms2048m -Xmx6144m"}"
java ${JVM_OPTS:-"-Xms2048m -Xmx6144m"} -jar forge-1.12.2-14.23.5.2860.jar nogui
EOF

chmod 755 run.sh
./run.sh