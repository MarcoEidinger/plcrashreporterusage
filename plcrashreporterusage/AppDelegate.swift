//
//  AppDelegate.swift
//  plcrashreporterusage
//
//  Created by Eidinger, Marco on 3/18/20.
//  Copyright © 2020 Eidinger, Marco. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var handleCrashReportOnStartup: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.setupCrashReporting()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        UnstableAppApi.handleCustomUrl(url)
        return true
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        UnstableAppApi.handleMemoryWarning()
    }
}

// https://blog.kulman.sk/logging-ios-app-crashes/
extension AppDelegate {
    func setupCrashReporting() {
        guard let crashReporter = PLCrashReporter.shared() else {
            return
        }

        if crashReporter.hasPendingCrashReport() && handleCrashReportOnStartup {
            handleCrashReport(crashReporter)
        }

        if !crashReporter.enable() {
            print("Could not enable crash reporter")
        }
    }

    func handleCrashReport(_ crashReporter: PLCrashReporter) {
        guard let crashData = try? crashReporter.loadPendingCrashReportDataAndReturnError(), let report = try? PLCrashReport(data: crashData), !report.isKind(of: NSNull.classForCoder()) else {
            crashReporter.purgePendingCrashReport()
            return
        }

        let crash: NSString = PLCrashReportTextFormatter.stringValue(for: report, with: PLCrashReportTextFormatiOS)! as NSString
        // process the crash report, send it to a server, log it, etc
        print("CRASH REPORT:\n \(crash)")
        crashReporter.purgePendingCrashReport()
    }
}

