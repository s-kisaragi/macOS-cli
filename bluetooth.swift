import Foundation

func manageBluetooth(_ action: String) {
    let task = Process()
    task.launchPath = "/usr/local/bin/blueutil" // Assuming blueutil is in /usr/local/bin

    switch action {
    case "on":
        task.arguments = ["-p", "1"]
    case "off":
        task.arguments = ["-p", "0"]
    default:
        print("Usage: bt on/off")
        return
    }

    task.launch()
    task.waitUntilExit()
}

let arguments = CommandLine.arguments

if arguments.count != 2 {
    print("Usage: bt on/off")
} else {
    manageBluetooth(arguments[1])
}
