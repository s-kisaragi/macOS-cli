import Foundation

func runShellCommand(_ command: String) -> String {
    let process = Process()
    process.launchPath = "/bin/zsh"
    process.arguments = ["-c", command]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return String(data: data, encoding: .utf8) ?? ""
}

let s3BucketListCommand = "aws s3 ls | awk '{print $3}' | grep -v -e '^$' -e 's3://'"
let s3BucketList = runShellCommand(s3BucketListCommand).split(separator: "\n").map { String($0) }

for bucket in s3BucketList {
    let directoryPath = "\(NSHomeDirectory())/s3/\(bucket)"
    
    // Check if the directory exists, if not, create it
    if !FileManager.default.fileExists(atPath: directoryPath) {
        do {
            try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error)")
        }
    }
    
    let mountCommand = "rclone mount s3:\(bucket) \(directoryPath)/ --daemon"
    runShellCommand(mountCommand)
    print("s3:\(bucket) mounted to \(directoryPath)")
}
