//
//  TotalCanvasView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/29.
//

import SwiftUI
import RealmSwift
import RxSwift
import RxRealm

struct TotalCanvasView: View {
    let subjectId:String
    var subjectModel:SubjectModel? {
        Realm.shared.object(ofType: SubjectModel.self, forPrimaryKey: subjectId)
    }
    var canvass:Results<CanvasModel> {
        Realm.shared.objects(CanvasModel.self).filter("deleted = %@ && subjectId = %@", false, subjectId)
    }
    let previewOnly:Bool
    @State var list:[CanvasModel.ThreadSafeModel] = []
    @Binding var pointer:(Int,Int)
    @Binding var size:CGFloat
    @State var count = 0
    var wc:Int {
        subjectModel?.width ?? 0
    }
    var hc:Int {
        subjectModel?.height ?? 0
    }
    
    var canvasSize:CGSize {
        print("model : \(UIDevice.current.model)")
        if UIDevice.current.model == "iPad" {
            return .init(width: 500, height: 500)
        }
        let w = UIScreen.main.bounds.width
        let h = UIScreen.main.bounds.height
        if w < h {
            return .init(width: w, height: w)
        }
        return .init(width: h, height: h)
    }
    
    func getDoteData(canvasId:String)->Results<DoteModel> {
        return Realm.shared.objects(DoteModel.self).filter("canvasId = %@", canvasId)
    }
    
    var canvas : some View {
        Canvas { ctx,size in
            ctx.draw(Text("\(count)"), in: .init(x: 0, y: -100, width: 50, height: 10))
            let iw = canvasSize.width / CGFloat(wc)
            let ih = canvasSize.height / CGFloat(hc)
            
            for canvas in list {
                let x = CGFloat(canvas.offsetX) * iw
                let y = CGFloat(canvas.offsetY) * ih
                let width = CGFloat(canvas.width) * iw
                let height = CGFloat(canvas.height) * ih
                let rect = CGRect(x: x, y: y, width: width, height: height)
                if !previewOnly {
                    ctx.stroke(.init(roundedRect: rect, cornerSize: .zero), with: .color(.orange))
                }
                
                for dote in getDoteData(canvasId: canvas.id) {
                    if dote.size == 0 {
                        let dx = CGFloat(dote.x) * iw + x
                        let dy = CGFloat(dote.y) * ih + y
                        let rect = CGRect(x: dx, y: dy, width: iw, height: ih)
                        ctx.fill(.init(roundedRect: rect, cornerSize: .zero), with: .color(dote.color))
                    }
                    else {
                        let model = dote.threadSafeModel
                        
                        ctx.blendMode = model.blendMode
                        for data in PathFinder.findPoints(drawType: model.drawTypeValue, center: (dote.x, dote.y), size: model.size) {
                            let dx = CGFloat(data.x) * iw + x
                            let dy = CGFloat(data.y) * ih + y
                            let rect = CGRect(x: dx, y: dy, width: iw, height: ih)
                            ctx.fill(.init(roundedRect: rect, cornerSize: .zero), with: .color(dote.color))
                        }
                    }
                }
            }

            if !previewOnly {
                let prect = CGRect(
                    x: CGFloat(pointer.0) * iw,
                    y: CGFloat(pointer.1) * ih ,
                    width: CGFloat(self.size) * iw,
                    height: CGFloat(self.size) * ih)
                ctx.fill(.init(roundedRect: prect, cornerSize: .zero), with: .color(.red.opacity(0.5)))
            }
        }
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ value in
            if previewOnly {
                return
            }
            func getIndex(location:CGPoint)->(Int,Int) {
                let x = Int(location.x / canvasSize.width * CGFloat(wc))
                let y = Int(location.y / canvasSize.height * CGFloat(hc))
                print("\(location), \(wc) \(hc)  \(x) : \(y)")
                return (x,y)
            }
            
            var newPointer = getIndex(location: value.location)
            if newPointer.0 < 0 {
                newPointer.0 = 0
            }
            if newPointer.1 < 0 {
                newPointer.1 = 0
            }
            if newPointer.0 + Int(size) >= wc {
                newPointer.0 = wc - 1 - Int(size)
            }
            if newPointer.1 + Int(size) >= hc {
                newPointer.1 = hc - 1 - Int(size)
            }
            pointer = newPointer
        }))
        .frame(width: canvasSize.width, height: canvasSize.height)
        .border(.primary)
    }
    var info : some View {
        VStack(alignment: .leading) {
            HStack {
                Text("size").foregroundColor(.primary)
                Text("\(Int(size))")
                Slider(value: $size, in: 8...32) {
                    Text("size")
                }.onChange(of: size) { newValue in
                    
                }
            }
            HStack {
                Text("offset")
                Text("x : \(pointer.0) y :\(pointer.1)")
            }
        }.padding(10)
    }
    let disposeBag = DisposeBag()
    var body: some View {
        VStack {
            if previewOnly {
                canvas
            }            
            else if canvasSize.width < canvasSize.height {
                HStack {
                    canvas
                    info
                }
            }
            else {
                VStack {
                    canvas
                    info
                }
            }
        }
        .onAppear {
            Observable.collection(from: Realm.shared.objects(DoteModel.self))
                .subscribe { event in
                    switch event {
                    case .next(_):
                        loadData()
                    default:
                        break
                    }
                }.disposed(by: disposeBag)
            loadData()
        }
        
        
    }
    func loadData() {
        list = canvass.map { model in
            return model.threadSafeModel
        }
        count += 1
    }
}

struct TotalCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        TotalCanvasView(
            subjectId:"test",
            previewOnly: true,
            list: [
                .init(id: "a", title: "b", onwerId: "c", subjectId:"", updateDt: 0, deleted: false, width: 32, height: 32, offsetX: 0, offsetY: 0),
                .init(id: "a", title: "b", onwerId: "c", subjectId:"", updateDt: 0, deleted: false, width: 16, height: 16, offsetX: 240, offsetY: 230),
            ],
            pointer: .constant((30,30)),
            size : .constant(64)
        )
    }
}
