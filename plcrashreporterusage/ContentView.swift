//
//  ContentView.swift
//  plcrashreporterusage
//
//  Created by Eidinger, Marco on 3/18/20.
//  Copyright © 2020 Eidinger, Marco. All rights reserved.
//

import SwiftUI
import MessageUI

struct ContentView: View {

    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false

    let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

    private var unstableApi = UnstableAppApi()
    private var handler: ConfigurationLoaderHandler = ConfigurationLoaderHandler()

    var body: some View {
        ScrollView {
            VStack {
                Button(action: {
                    self.handler.load()
                }) {
                    Text("Generate Crash (involes SAPFramework)")
                }.padding()

                Button(action: {
                    self.unstableApi.fatalFlow()
                }) {
                    Text("Generate Crash (fatalExit)")
                }.padding()

                Button(action: {
                    self.unstableApi.lotsOfData()
                }) {
                    Text("Generate Crash (Memory Overflow)")
                }.padding()

                Button(action: {
                    self.unstableApi.tryToAccessVariable()
                }) {
                    Text("Generate Crash (Invalid Memory Access)")
                }.padding()

                Button(action: {
                    self.unstableApi.tryToAccessVariableAsync()
                }) {
                    Text("Generate Crash (Async Invalid Memory Access)")
                }.padding()

                Button(action: {
                    self.unstableApi.mathIsComplicated()
                }) {
                    Text("Generate Crash (Division by zero)")
                }.padding()

                Button(action: {
                    self.unstableApi.outOfBounds()
                }) {
                    Text("Generate Crash (outOfBounds)")
                }.padding()

                Button(action: {
                    self.unstableApi.floatUntilCrash()
                }) {
                    Text("Generate Crash (float)")
                    .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
                        self.unstableApi.handleShake()
                    }
                }.padding()

                Text(appVersionString)
                    .padding()

                Button(action: {
                    self.isShowingMailView.toggle()
                }) {
                    Text("Export Crash Report via Email")
                }
                .disabled(!MFMailComposeViewController.canSendMail())
                .sheet(isPresented: $isShowingMailView) {
                    MailView(result: self.$result)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension NSNotification.Name {
    public static let deviceDidShakeNotification = NSNotification.Name("MyDeviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        NotificationCenter.default.post(name: .deviceDidShakeNotification, object: event)
    }
}
