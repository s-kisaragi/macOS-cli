import Foundation

func getPassword() -> String? {
    var password: String?

    // Use getpass to securely input the password without displaying it
    if let passPointer = getpass("Enter Shared Secret: ") {
        password = String(cString: passPointer)
    }

    return password
}

func manageVPN(_ action: String, _ serviceName: String, _ sharedSecret: String?) {
    let task = Process()
    task.launchPath = "/usr/sbin/scutil"
    
    switch action {
    case "on":
        if let secret = sharedSecret {
            task.arguments = ["--nc", "start", serviceName, "--secret", secret]
        } else {
            print("Error: Shared Secret is missing. Usage: vpn on [service-name]")
            return
        }
    case "off":
        task.arguments = ["--nc", "stop", serviceName]
    case "status":
        task.arguments = ["--nc", "status", serviceName]
    default:
        print("Usage: vpn on/off/status [service-name]")
        return
    }
    
    task.launch()
    task.waitUntilExit()
}

let arguments = CommandLine.arguments

if arguments.count != 3 {
    print("Usage: vpn on/off/status [service-name]")
} else {
    let sharedSecret = getPassword()
    manageVPN(arguments[1], arguments[2], sharedSecret)
}
