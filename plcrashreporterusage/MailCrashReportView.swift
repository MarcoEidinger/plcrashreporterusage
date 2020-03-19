//
//  MailCrashReportView.swift
//  plcrashreporterusage
//
//  Created by Eidinger, Marco on 3/18/20.
//  Copyright © 2020 Eidinger, Marco. All rights reserved.
//

import SwiftUI
import UIKit
import MessageUI

struct MailView: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                           result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setMessageBody(getCrashReport(), isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }

    func getCrashReport() -> String {
        guard let crashReporter = PLCrashReporter.shared() else {
            return ""
        }
        if crashReporter.hasPendingCrashReport() {
                        guard let crashData = try? crashReporter.loadPendingCrashReportDataAndReturnError(), let report = try? PLCrashReport(data: crashData), !report.isKind(of: NSNull.classForCoder()) else {
                crashReporter.purgePendingCrashReport()
                return ""
            }

            let crash: NSString = PLCrashReportTextFormatter.stringValue(for: report, with: PLCrashReportTextFormatiOS)! as NSString
            crashReporter.purgePendingCrashReport()
            return crash as String
        }
        return ""
    }
}
