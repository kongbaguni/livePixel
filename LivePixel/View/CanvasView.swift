//
//  CanvasView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/23.
//

import SwiftUI
import RealmSwift
struct CanvasView: View {
    enum AlertType {
        case deletedCanvas
    }
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let id:String
    var canvasData:CanvasModel? {
#if !targetEnvironment(simulator)
        return Realm.shared.object(ofType: CanvasModel.self, forPrimaryKey: id)
#else
        return nil
#endif
    }
    
    @State var isActionSheet = false
    @State var isAlert = false
    @State var alertType:AlertType? = nil {
        didSet {
            isAlert = alertType != nil
        }
    }
    
    var body: some View {
        VStack {
            Canvas { context, size in
                
            }
        }
        .navigationTitle(Text(canvasData?.title ?? "id"))
        .toolbar {
            Button {
                isActionSheet = true
            } label: {
                Image(systemName: "line.3.horizontal")
            }
        }
        .onAppear {
            if canvasData?.deleted == true {
                alertType = .deletedCanvas
            }
        }
        .actionSheet(isPresented: $isActionSheet) {
            var buttons:[ActionSheet.Button] = []
            if canvasData?.ownerId == AuthManager.shared.userId {
                buttons.append(ActionSheet.Button.default(Text("delete canvas"), action: {
                    FirestoreHelper.deleteCanvas(canvasId: id) { error in
                        if error == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }))
            }
            buttons.append(.cancel())
        
            return .init(title: Text("action"),buttons: buttons)
        }
        .alert(isPresented: $isAlert) {
            switch alertType {
            case .deletedCanvas:
                return .init(title: Text("alert"), message: Text("deleted canvas alert msg"), dismissButton: .default(Text("confirm"), action: {
                    presentationMode.wrappedValue.dismiss()
                }))
            default:
                return .init(title: Text("error"))
            }
        }
        
    }
}

struct CanvasView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView(id:"aaa")
    }
}
