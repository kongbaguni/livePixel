//
//  MakeNewCanvasView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/25.
//

import SwiftUI
import RealmSwift

struct MakeNewCanvasView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let subjectId:String
    var subjectModel:SubjectModel? {
        return Realm.shared.object(ofType: SubjectModel.self, forPrimaryKey: subjectId)
    }
    
    @State var title:String = ""
    @State var errMsg:Text? = nil {
        didSet {
            if errMsg != nil {
                isAlert = true
                isLoading = false 
            }
        }
    }
    
    
    @State var isAlert = false
    @State var size:CGFloat = 16
    @State var offset:(Int,Int) = (0,0)
    @State var isLoading = false
    var body: some View {
        ScrollView {
            Section("make new canvas") {
                HStack {
                    Text("subject")
                    Text("\(subjectModel?.title ?? subjectId)")
                }
                HStack {
                    Text("canvas title")
                    TextField("input canvas title", text: $title)
                        .textFieldStyle(.roundedBorder)
                }
                TotalCanvasView(subjectId:subjectId, previewOnly : false ,pointer: $offset, size: $size)

            }.padding(10)
            
            RoundedButton(title: Text("confirm"), isLoading: $isLoading) {
                isLoading = true
                let trimmingTitle = title.trimmingCharacters(in: CharacterSet(charactersIn: " "))
                if trimmingTitle.isEmpty {
                    errMsg = Text("empty title msg")
                    return
                }
                FirebaseFirestoreHelper.shared.makeCanvas(
                    subjectId:subjectId,
                    title: trimmingTitle,
                    width: Int(size),
                    height: Int(size),
                    offset: offset) { error in
                    isLoading = false
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
        .onAppear {
#if !targetEnvironment(simulator)
            if let last = Realm.shared.objects(CanvasModel.self).filter("subjectId = %@", subjectId).last {
                offset = (last.offsetX, last.offsetY)
                size = CGFloat(last.width)
            }
#endif
        }
    }
}

struct MakeNewCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        MakeNewCanvasView(subjectId: "")
    }
}
