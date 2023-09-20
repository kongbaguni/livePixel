//
//  MakeSubjectView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/30.
//

import SwiftUI
import RealmSwift

struct MakeSubjectView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var title:String = ""
    @State var size:CGFloat = 256
    @State var isLoading = false
    @State var color:Color = Realm.shared.objects(SubjectModel.self).last?.threadSafeModel.bgColor ?? .clear
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
                Slider(value: $size, in: 64...256)
            }
            ColorPicker(selection: $color) {
                Text("background color")
            }
            RoundedButton(title: Text("make"), isLoading: $isLoading) {
                isLoading = true
                FirebaseFirestoreHelper.shared.makeSubject(title: title, width: Int(size), height: Int(size), backgroundColor: color) { error in
                    isLoading = false
                    presentationMode.wrappedValue.dismiss()
                }
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
