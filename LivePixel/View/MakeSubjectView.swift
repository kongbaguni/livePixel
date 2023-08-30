//
//  MakeSubjectView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/30.
//

import SwiftUI

struct MakeSubjectView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var title:String = ""
    @State var size:CGFloat = 1024
    @State var isLoading = false
    var body: some View {
        List {
            HStack {
                Text("title")
                TextField("input title", text: $title)
                    .textFieldStyle(.roundedBorder)
            }
            HStack {
                Text("size")
                Text("\(Int(size))")
                Slider(value: $size, in: 128...2048)
            }
            RoundedButton(title: Text("make"), isLoading: $isLoading) {
                isLoading = true
#if !targetEnvironment(simulator)
                FirebaseFirestoreHelper.shared.makeSubject(title: title, width: Int(size), height: Int(size)) { error in
                    isLoading = false
                    presentationMode.wrappedValue.dismiss()
                }
#endif
            }
        }
        .navigationTitle("make subject")
    }
}

struct MakeSubjectView_Previews: PreviewProvider {
    static var previews: some View {
        MakeSubjectView()
    }
}
