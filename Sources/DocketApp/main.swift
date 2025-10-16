import AppKit
import DocketKit

// Custom main entry point that creates and runs the app delegate
NSApplication.shared.delegate = AppDelegate()
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
