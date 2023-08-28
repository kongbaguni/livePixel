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
    @State var pointer:(Int,Int) = (0,0)
    @State var color:Color = .red
    @State var dotes:[DoteModel.ThreadSafeModel] = []
    
    var wc:Int {
        canvasData?.width ?? 32
    }
    var hc:Int {
        canvasData?.height ?? 32
    }
    var canvasSize:CGSize {
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        if w < h {
            if wc > hc {
                return .init(width: w, height: w / CGFloat(hc) * CGFloat(wc))
            }

            return .init(width: w, height: w)
        }
        return .init(width: h, height: h)
    }
    
    func makeDote() {
        FirestoreHelper.makeDote(canvasId: id, position: pointer, color: color)
    }
    
    func loadData() {
        dotes = []
        let data = Realm.shared.objects(DoteModel.self).filter("canvasId = %@", id)
        for item in data {
            dotes.append(item.threadSafeModel)
        }
    }
    
    var body: some View {
        ScrollView {
            Canvas { context, size in
                context.blendMode = .normal
                let wc = canvasData?.width ?? 32
                let hc = canvasData?.height ?? 32
                
                let width = size.width / CGFloat(wc)
                let height = size.height / CGFloat(hc)
                for i in 0..<wc {
                    for j in 0..<hc {
                        
                        let x = CGFloat(i) * width
                        let y = CGFloat(j) * height
                        let rect = CGRect(x: x, y: y, width: width, height: height)
                        context.stroke(.init(roundedRect: rect, cornerSize: .zero), with: .color(.blue))
                    }
                }
                
                context.blendMode = .normal
                let data = Realm.shared.objects(DoteModel.self).filter("canvasId = %@", id)
                
                for dote in data {
                    let rect = CGRect(x: CGFloat(dote.x) * width, y: CGFloat(dote.y) * height, width: width, height: height)
                    context.fill(.init(roundedRect: rect, cornerSize: .zero), with: .color(.black))
                
                }

                
                let rect = CGRect(
                    x: CGFloat(pointer.0) * width ,
                    y: CGFloat(pointer.1) * height,
                    width: width,
                    height: height
                )
                context.blendMode = .xor
                context.stroke(.init(roundedRect: rect, cornerSize: .zero), with: .color(.red), lineWidth: 3)
                

                
            }
            .frame(width: canvasSize.width, height: canvasSize.width)
            .background(.white)
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ value in

                func getIndex(location:CGPoint)->(Int,Int) {
                    
                    let x = Int(location.x / canvasSize.width * CGFloat(wc))
                    let y = Int(location.y / canvasSize.height * CGFloat(hc))
                    print("\(location), \(wc) \(hc)  \(x) : \(y)")
                    return (x,y)
                }
                
                pointer = getIndex(location: value.location)
                
                if pointer.0 < 0 {
                    pointer.0 = 0
                }
                if pointer.1 < 0 {
                    pointer.1 = 0
                }
                if pointer.0 >= wc {
                    pointer.0 = wc - 1
                }
                if pointer.1 >= hc {
                    pointer.1 = hc - 1
                }
                
            }))
            
            Button{
                FirestoreHelper.makeDote(canvasId: id, position: pointer, color: color)
            } label: {
                Text("make")
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
                NotificationCenter.default.post(name: .canvasDidDeleted, object: id)
            }
            loadData()
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
