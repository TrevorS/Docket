import AppKit
import DocketKit

// Custom main entry point that creates and runs the app delegate
let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
