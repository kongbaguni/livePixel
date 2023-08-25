//
//  MakeNewCanvasView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/25.
//

import SwiftUI

struct MakeNewCanvasView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var title:String = ""
    @State var errMsg:Text? = nil {
        didSet {
            if errMsg != nil {
                isAlert = true
            }
        }
    }
    
    
    @State var isAlert = false
    var body: some View {
        VStack {
            HStack {
                Text("canvas title")
                TextField("input canvas title", text: $title)
            }.padding(20)
            RoundedButton(title: Text("confirm")) {
                let trimmingTitle = title.trimmingCharacters(in: CharacterSet(charactersIn: " "))
                if trimmingTitle.isEmpty {
                    errMsg = Text("empty title msg")
                    return
                }
                FirestoreHelper.makeCanvas(title: trimmingTitle) { error in
                    if let err = error {
                        self.errMsg = Text(err.localizedDescription)
                    }
                    else  {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationTitle(Text("make new canvas"))
        .alert(isPresented: $isAlert) {
            .init(title: Text("alert"),message: errMsg ?? Text(""))
        }
    }
}

struct MakeNewCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        MakeNewCanvasView()
    }
}
