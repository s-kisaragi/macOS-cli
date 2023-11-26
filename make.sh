swiftc -o bluetooth bluetooth.swift
swiftc -o vpn vpn.swift
swiftc -o wlan wlan.swift

cp bluetooth /usr/local/bin
cp vpn /usr/local/bin
cp wlan /usr/local/bin

rm -rf wlan vpn bluetooth