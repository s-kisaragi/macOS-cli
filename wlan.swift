import Foundation

func setWiFiPower(_ state: String) {
    let task = Process()
    task.launchPath = "/usr/sbin/networksetup"
    
    if state == "on" {
        task.arguments = ["-setairportpower", "en0", "on"]
    } else if state == "off" {
        task.arguments = ["-setairportpower", "en0", "off"]
    } else {
        print("Usage: setWiFiPower on/off")
        return
    }
    
    task.launch()
    task.waitUntilExit()
}

let arguments = CommandLine.arguments

if arguments.count != 2 {
    print("Usage: setWiFiPower on/off")
} else {
    setWiFiPower(arguments[1])
}
