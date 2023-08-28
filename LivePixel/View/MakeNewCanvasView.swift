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
    @State var size:CGFloat = 64
    
    var body: some View {
        ScrollView {
            Section("make new canvas") {
                HStack {
                    Text("canvas title")
                    TextField("input canvas title", text: $title)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("size")
                    Text(String(format: "%0.0f", floor(size)))
                    Spacer()
                    Slider(value: $size, in: 8...16)
                        .frame(width:UIScreen.main.bounds.width - 130)
                }
                

            }.padding(10)
            
            RoundedButton(title: Text("confirm")) {
                let trimmingTitle = title.trimmingCharacters(in: CharacterSet(charactersIn: " "))
                if trimmingTitle.isEmpty {
                    errMsg = Text("empty title msg")
                    return
                }
                FirestoreHelper.makeCanvas(title: trimmingTitle, width: Int(size), height: Int(size)) { error in
                    if let err = error {
                        self.errMsg = Text(err.localizedDescription)
                    }
                    else  {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
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
