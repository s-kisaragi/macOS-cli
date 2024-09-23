import Foundation

// Usage function
func usage() {
    print("Usage: script [-u | --unmount]")
    exit(1)
}

let fileManager = FileManager.default
let homeDirectory = fileManager.homeDirectoryForCurrentUser
let s3Directory = homeDirectory.appendingPathComponent("s3")

// Get the list of S3 buckets
func listS3Buckets() -> [String] {
    let process = Process()
    process.launchPath = "/usr/bin/aws"
    process.arguments = ["s3", "ls"]

    let pipe = Pipe()
    process.standardOutput = pipe
    process.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    
    return output.split(separator: "\n").compactMap { line in
        let components = line.split(separator: " ")
        return components.count > 2 ? String(components[2]) : nil
    }
}

// Mount S3 buckets
func mountS3Buckets(buckets: [String]) {
    for bucket in buckets {
        let bucketPath = s3Directory.appendingPathComponent(bucket)
        if !fileManager.fileExists(atPath: bucketPath.path) {
            try? fileManager.createDirectory(at: bucketPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        let process = Process()
        process.launchPath = "/usr/bin/rclone"
        process.arguments = ["mount", "s3:\(bucket)", bucketPath.path, "--daemon"]
        process.launch()
        
        print("s3:\(bucket) mounted to \(bucketPath.path)")
    }
}

// Unmount S3 buckets
func unmountS3Buckets(buckets: [String]) {
    for bucket in buckets {
        let bucketPath = s3Directory.appendingPathComponent(bucket)
        
        let process = Process()
        process.launchPath = "/usr/bin/umount"
        process.arguments = [bucketPath.path]
        process.launch()
        
        print("Unmounted \(bucketPath.path)")
        
        if fileManager.fileExists(atPath: bucketPath.path) {
            try? fileManager.removeItem(at: bucketPath)
        }
    }
}

// Main execution
let arguments = CommandLine.arguments.dropFirst()
let s3BucketList = listS3Buckets()

if arguments.isEmpty {
    // No arguments, mount S3 buckets
    mountS3Buckets(buckets: s3BucketList)
    exit(0)
}

// Parse command line options
var unmount = false

for arg in arguments {
    switch arg {
    case "-u", "--unmount":
        unmount = true
    default:
        usage()
    }
}

if unmount {
    unmountS3Buckets(buckets: s3BucketList)
}
