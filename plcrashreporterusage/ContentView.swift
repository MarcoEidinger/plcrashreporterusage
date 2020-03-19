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

     var body: some View {
        VStack {
            Button(action: {
                fatalError("Generated crash for testing")
            }) {
                Text("Generate Crash")
            }.padding()

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
