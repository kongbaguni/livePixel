//
//  CanvasListView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/25.
//

import SwiftUI
import RealmSwift

struct CanvasListView: View {
    let subjectId:String
    enum SheetType {
        case makeNewCanvas
    }
    @State var canvasSet:Set<CanvasModel.ThreadSafeModel> = []

    @State var isSheet = false
    @State var sheetType:SheetType = .makeNewCanvas {
        didSet {
            isSheet = true
        }
    }
    
    init(subjectId:String,canvasList: [CanvasModel.ThreadSafeModel]) {
        self.subjectId = subjectId
        self.canvasSet = Set(canvasList)
    }
    @State var count = 0
    
    init(subjectId:String) {
        self.subjectId = subjectId
    }
    var subjectModel : SubjectModel? {
        return Realm.shared.object(ofType: SubjectModel.self, forPrimaryKey: subjectId)
    }
    
    func makeLabel(data:CanvasModel.ThreadSafeModel)-> some View {
        HStack(alignment: .top) {
            Canvas { ctx, size in
                
                if let color = subjectModel?.bgColor {
                    ctx.fill(.init(roundedRect: .init(origin: .zero, size: size), cornerSize: .zero), with: .color(color))
                }
                ctx.draw(Text("\(count)"), in: .init(x: 0, y: -100, width: 30, height: 30))
                
                for item in Realm.shared.objects(DoteModel.self).filter("canvasId = %@", data.id) {
                    if item.size == 0 {
                        let rect = CGRect(x: CGFloat(item.x) * 3,
                                          y: CGFloat(item.y) * 3,
                                          width: 3,
                                          height: 3)
                        ctx.fill(.init(roundedRect: rect, cornerSize: .zero), with: .color(item.color))
                    }
                    else {
                        let model = item.threadSafeModel
                        ctx.blendMode = model.blendMode
                        for data in PathFinder.findPoints(drawType: model.drawTypeValue, center: (item.x, item.y), size: item.size) {
                            let rect = CGRect(x: data.x * 3 , y: data.y * 3, width: 3, height: 3)
                            
                            ctx.fill(.init(roundedRect: rect, cornerSize: .zero), with: .color(item.color))
                        }
                    }
                }
            }
            .frame(width:CGFloat(data.width * 3), height:CGFloat(data.height * 3))
            .border(Color.primary)
            .onAppear {
                FirebaseFirestoreHelper.shared.getDotes(canvasId: data.id) { list, error in
                    count += 1
                }
            }

        }.frame(height: 200)
    }
    var canvasListView : some View {
        var data : some View {
            Group {
                if canvasSet.count > 0 {
                    ForEach(canvasSet.sorted(by: { a, b in
                        a.updateDt > b.updateDt
                    }), id: \.self) { canvas in
                        NavigationLink {
                            CanvasView(id: canvas.id)
                        } label: {
                            makeLabel(data: canvas)
                        }
                    }
                }
            }
        }
        
        return ScrollView(UIDevice.current.isiPad ? .vertical : .horizontal) {
            if UIDevice.current.isiPad {
                LazyVGrid(columns: [.init(.flexible()),.init(.flexible()),.init(.flexible())]) {
                    data
                }
            }
            else {
                LazyHGrid(rows: [.init(.flexible())]) {
                    data
                }
            }
        }
    }
    var totalCanvasView: some View {
        TotalCanvasView(subjectId: subjectId, previewOnly: true, pointer: .constant((0,0)), size: .constant(0))
    }
    var makeNewCanvasBtn : some View {
        NavigationLink {
            MakeNewCanvasView(subjectId:subjectId)
        } label: {
            RoundedLabel(title: Text("make new canvas"), style: .defaultStyle)
        }
    }
    var emptyListView : some View {
        Group {
            if canvasSet.count == 0 {
                Text("empty list msg")
            }
        }
    }
    
    var body: some View {
        Group {
            if UIDevice.current.isiPad {
                HStack {
                    VStack {
                        totalCanvasView
                        makeNewCanvasBtn
                        Spacer()
                    }
                    emptyListView
                    canvasListView
                }
                
            } else {
                ScrollView {
                    canvasListView
                    totalCanvasView
                    
                    emptyListView
                    makeNewCanvasBtn
                }
            }
        }
        .onAppear {
            loadData()
        }
        .refreshable {
            reload()
        }
        .onReceive(NotificationCenter.default.publisher(for: .canvasDidDeleted)) { noti in
            removeDeleted()
        }
        .onReceive(NotificationCenter.default.publisher(for: .canvasDidCreated)) { noti in
            reload()
        }
        .onReceive(NotificationCenter.default.publisher(for: .doteDidCreated)) { noti in
            count += 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .canvasDidEdited)) { noti in
            canvasSet.removeAll()
            loadData()
        }
        .sheet(isPresented: $isSheet) {
            MakeNewCanvasView(subjectId:subjectId)
        }
        .navigationTitle(Text("\(subjectModel?.title ?? subjectId)"))

    }
    
    func reload() {
        FirebaseFirestoreHelper.shared.getCanvasList(subjectId:subjectId) { list, error in
            // 신규 켄버스 추가
            for item in list {
                canvasSet.insert(item)
            }
            
            removeDeleted()

        }
    }
    
    func removeDeleted() {
        for canvas in canvasSet {
            if canvas.deletedNow {
                canvasSet.remove(canvas)
            }
        }
    }
    
    func loadData() {
        if canvasSet.count == 0 {
            for model in Realm.shared.objects(CanvasModel.self).filter("subjectId = %@", subjectId) {
                if model.deleted == false {
                    canvasSet.insert(model.threadSafeModel)
                }
            }
        }
        FirebaseFirestoreHelper.shared.getCanvasList(subjectId:subjectId) { list, error in
            for item in list {
                if item.deletedNow == false {
                    canvasSet.insert(item)
                }
            }
        }
    }
}

struct CanvasListView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            CanvasListView(
                subjectId: " ",
                canvasList: [
                .init(id: "aaaa",
                      onwerId: "djskala",
                      subjectId: " ",
                      updateDt: 1010123, deleted: false , width : 32, height: 32, offsetX: 0, offsetY: 0),
                .init(id: "aaba",
                      onwerId: "djskala",
                      subjectId: " ",
                      updateDt: 1032800, deleted: true, width : 32, height: 32, offsetX: 0, offsetY: 0),

            ])
        }
    }
}
