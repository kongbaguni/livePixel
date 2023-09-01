//
//  EdItCanvasInfoView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/09/01.
//

import SwiftUI
import RealmSwift

struct EdItCanvasInfoView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let id:String
    var model:CanvasModel? {
        Realm.shared.object(ofType: CanvasModel.self, forPrimaryKey: id)
    }
    var subjectModel:SubjectModel? {
        if let m = model {
            return Realm.shared.object(ofType: SubjectModel.self, forPrimaryKey: m.subjectId)
        }
        return nil
    }
    @State var title:String = ""
    @State var offset:(Int,Int) = (0,0)
    @State var size:CGFloat = 0
    @State var isLoading:Bool = false
        
    var body: some View {
        List {
            HStack {
                Text("subject")
                Text("\(subjectModel?.title ?? model?.subjectId ?? "" )")
            }
            HStack {
                Text("canvas title")
                TextField("input canvas title", text: $title)
                    .textFieldStyle(.roundedBorder)
            }
            TotalCanvasView(subjectId:model?.subjectId ?? "", previewOnly : false ,pointer: $offset, size: $size)
            RoundedButton(title: Text("save"), isLoading: $isLoading) {
                isLoading = true
                FirebaseFirestoreHelper.shared.editCanvas(canvasId:id ,subjectId: model?.subjectId ?? "",
                                                          title: title,
                                                          width: Int(size), height: Int(size),
                                                          offset: offset) { error in
                    FirebaseFirestoreHelper.shared.getCanvasList(subjectId: model!.subjectId) { list, error in
                        isLoading = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }.onAppear {
            title = model?.title ?? ""
            offset = (model?.offsetX ?? 0, model?.offsetY ?? 0)
            size = CGFloat(model?.width ?? 0)
        }
    }
}
