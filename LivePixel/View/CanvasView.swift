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
        case deleteCanvas
        case deletedCanvas
    }
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let id:String
    var canvasData:CanvasModel? {
        Realm.shared.object(ofType: CanvasModel.self, forPrimaryKey: id)
    }
    var subjectModel:SubjectModel? {
        canvasData?.subjectModel
    }
    
    @State var drawCount = 0
    @State var doteCount = 0
    @State var isActionSheet = false
    @State var isAlert = false
    @State var alertType:AlertType? = nil {
        didSet {
            isAlert = alertType != nil
        }
    }
    @State var pointer:(Int,Int) = (0,0)
    @State var blendMode:GraphicsContext.BlendMode = .normal
    @AppStorage("pointerSize") var pointerSize:Double = 0
    
    var poinerViewPoints:Set<PathFinder.Point> {
        return PathFinder.findPoints(drawType: drawType, center: pointer, size: Int(pointerSize))
    }
    
    @State var color:Color = .blue
    
    
    @State var dotes:[DoteModel.ThreadSafeModel] = []
    @AppStorage("drawType") var drawType:DoteModel.DrawType = .circle
    @AppStorage("isDraw") var isDraw:Bool = true
    @State var isPresented:Bool = false
    enum PresentViewType {
        case canvasInfomation
        case canvasEdit
    }
    @State var presenteViewType:PresentViewType? = nil
    
    var doteData:ReversedCollection<Slice<Results<DoteModel>>> {
        DoteModel.limitedResult(canvasId: id, limit: 100)
    }
    
    var lastMyDote:DoteModel.ThreadSafeModel? {
        if let id = AuthManager.shared.userId {
            return Realm.shared.objects(DoteModel.self).filter("ownerId = %@", id).last?.threadSafeModel
        }
        return nil
    }
    
    
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
        FirebaseFirestoreHelper.shared.makeDote(canvasId: id, position: pointer, size: Int(pointerSize) ,color: color, type: drawType, blendMode: blendMode)
    }
    
    func loadData() {
        FirebaseFirestoreHelper.shared.getDotes(canvasId: id) { list, error in
            doteCount = doteData.count
        }
    }
    
    var canvas : some View {
        Canvas { context, size in
            context.draw(Text("\(drawCount)"), in: .init(x:0, y:0, width: 100, height: 50))
            context.draw(Text("\(doteCount)"), in: .init(x: 0, y: 0, width: 100, height: 50))
            
            context.blendMode = .normal
            if let color = subjectModel?.bgColor {
                context.fill(.init(roundedRect: .init(origin: .zero, size: size), cornerSize: .zero), with: .color(color))
            }
            let wc = canvasData?.width ?? 32
            let hc = canvasData?.height ?? 32
            
            let width = size.width / CGFloat(wc)
            let height = size.height / CGFloat(hc)
            
            for dote in doteData {
                let color = Color( .sRGB,red: dote.red, green: dote.green, blue: dote.blue, opacity: dote.opacicy)
                if dote.size == 0 {
                    let rect = CGRect(x: CGFloat(dote.x) * width, y: CGFloat(dote.y) * height, width: width, height: height)
                    context.fill(.init(roundedRect: rect, cornerSize: .zero), with: .color(color))
                }
                
                let model = dote.threadSafeModel
                context.blendMode = model.blendMode
                for item in PathFinder.findPoints(drawType: model.drawTypeValue, center: (model.x, model.y), size: model.size) {
                    let rect = CGRect(x: CGFloat(item.x) * width, y: CGFloat(item.y) * height, width: width, height: height)
                    context.fill(.init(roundedRect: rect, cornerSize: .zero), with: .color(color))
                }
            }

            context.blendMode = .normal
            for i in 0..<wc {
                for j in 0..<hc {
                    
                    let x = CGFloat(i) * width
                    let y = CGFloat(j) * height
                    let rect = CGRect(x: x, y: y, width: width, height: height)
                    context.stroke(.init(roundedRect: rect, cornerSize: .zero), with: .color(.blue))
                }
            }

           
            for point in poinerViewPoints {
                let rect = CGRect(
                    x: CGFloat(point.x) * width ,
                    y: CGFloat(point.y) * height,
                    width: width,
                    height: height
                )
                let path:Path = .init(roundedRect: rect, cornerSize: .zero)
                context.blendMode = blendMode
                context.fill(path, with: .color(color))
                context.blendMode = .xor
                context.stroke(path, with: .color(.red), lineWidth: 3)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                drawCount += 1
                loadData()
            }
            
        }
        
        .frame(width: canvasSize.width, height: canvasSize.width)
        
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ value in

            func getIndex(location:CGPoint)->(Int,Int) {
                
                let x = Int(location.x / canvasSize.width * CGFloat(wc))
                let y = Int(location.y / canvasSize.height * CGFloat(hc))
                print("\(location), \(wc) \(hc)  \(x) : \(y)")
                return (x,y)
            }
            
            var newPointer = getIndex(location: value.location)
            var isMakeDote = false
            if newPointer.0 < 0 {
                newPointer.0 = 0
            }
            if newPointer.1 < 0 {
                newPointer.1 = 0
            }
            if newPointer.0 >= wc {
                newPointer.0 = wc - 1
            }
            if newPointer.1 >= hc {
                newPointer.1 = hc - 1
            }
            if pointer != newPointer && isDraw {
                isMakeDote = true
            }
            pointer = newPointer
            if isMakeDote {
                makeDote()
            }
            
        }))
        .onLongPressGesture {
            makeDote()
        }
    }
    var pallete : some View {
        Group {
            VStack {
                BlendmodeSelectView(blendMode: $blendMode)
                DrawTypeSelector(type: $drawType)
                HStack(alignment: .top) {
                    Toggle(isOn: $isDraw) {
                        if isDraw == false {
                            Button{
                                FirebaseFirestoreHelper.shared.makeDote(canvasId: id, position: pointer, size:Int(pointerSize), color: color,type: drawType, blendMode: blendMode)
                            } label: {
                                Image(systemName: "pencil.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.primary)
                            }
                        }
                        else {
                            Image(systemName: "pencil.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.primary)
                        }
                    }.frame(width: 100)
                }
                HStack{
                    Slider(value: $pointerSize, in: 0...20) {
                        Text("size")
                    }.onChange(of: pointerSize){ newValue in
                        
                    }
                }
            }
            
            ColorMixerView(color: $color)

        }
    }
    var body: some View {
        Group {
            if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
                HStack {
                    canvas
                    VStack {
                        pallete
                    }
                }
            } else {
                ScrollView {
                    canvas
                    pallete
                }
            }
        }
        .navigationDestination(isPresented: $isPresented) {
            switch presenteViewType {
            case .canvasEdit:
                EdItCanvasInfoView(id: id)
            default:
                CanvasInfomationView(id: id)
            }
        }
        .navigationTitle(Text(canvasData?.id ?? "id"))
        .toolbar {
            
            Button {
                isPresented = true
                presenteViewType = .canvasInfomation
            } label : {
                Image(systemName: "info.circle.fill")
            }
            
            if canvasData?.ownerId == AuthManager.shared.userId {
                Button {
                    isPresented = true
                    presenteViewType = .canvasEdit
                } label : {
                    Image(systemName: "pencil")
                }

                Button {
                    isAlert = true
                    alertType = .deleteCanvas
                } label: {
                    Image(systemName: "trash")
                }
                                                
            }

        }
        .onAppear {
            if canvasData?.deleted == true {
                alertType = .deletedCanvas
                NotificationCenter.default.post(name: .canvasDidDeleted, object: id)
            }
            loadData()
            DispatchQueue.main.async {
                color = lastMyDote?.color ?? .black
            }
            
            if let last = lastMyDote {
                pointer.0 = last.x
                pointer.1 = last.y
            }
        }
        
        .alert(isPresented: $isAlert) {
            switch alertType {
            case .deletedCanvas:
                return .init(title: Text("alert"), message: Text("deleted canvas alert msg"), dismissButton: .default(Text("confirm"), action: {
                    presentationMode.wrappedValue.dismiss()
                }))
            case .deleteCanvas:
                return .init(title: Text("alert"),
                             message: Text("delete canvas alert msg"),
                             primaryButton: .default(Text("confirm"), action : {
                    FirebaseFirestoreHelper.shared.deleteCanvas(canvasId: id) { error in
                        if error == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }), secondaryButton: .cancel())
                
            default:
                return .init(title: Text("error"))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .doteDidCreated)) { noti in
            doteCount = doteData.count
        }
        
        
        
    }
}

struct CanvasView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView(id:"aaa")
    }
}
