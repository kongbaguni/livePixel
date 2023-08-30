//
//  CanvasListView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/25.
//

import SwiftUI
import RxSwift
import RxRealm
import RealmSwift

struct CanvasListView: View {
    enum SheetType {
        case makeNewCanvas
    }
    @State var newCanvasList:[CanvasModel.ThreadSafeModel] = []
    @State var canvasList:[CanvasModel.ThreadSafeModel] = []

    @State var isSheet = false
    @State var sheetType:SheetType = .makeNewCanvas {
        didSet {
            isSheet = true
        }
    }
    
    let disposeBag = DisposeBag()
    init(canvasList: [CanvasModel.ThreadSafeModel]) {
        self.canvasList = canvasList
    }
    @State var count = 0
    
    init() {
#if !targetEnvironment(simulator)
        Observable.collection(from: Realm.shared.objects(CanvasModel.self)).subscribe {[self]  event in
            switch event {
            case .next(let result):
                let newList:[CanvasModel.ThreadSafeModel] = result.map({ model in
                    return model.threadSafeModel
                })
                self.canvasList = newList
                break
            default:
                break
            }
        }.disposed(by: self.disposeBag)
#endif
    }
    
    func makeLabel(data:CanvasModel.ThreadSafeModel)-> some View {
        HStack {
            Canvas { ctx, size in
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
                        for data in PathFinder.findCircle(center: .init(x: item.x, y: item.y), end: .init(x: item.x + Int(item.size), y: item.y)) {
                            let rect = CGRect(x: data.x * 3 , y: data.y * 3, width: 3, height: 3)
                            
                            ctx.fill(.init(roundedRect: rect, cornerSize: .zero), with: .color(item.color))
                        }
                    }
                }
            }
            .frame(width:CGFloat(data.width * 3),height:CGFloat(data.height * 3))
            .border(Color.primary)
//            Text(data.title)
        }
    }
    var body: some View {
        ScrollView {
            TotalCanvasView(previewOnly: true, pointer: .constant((0,0)), size: .constant(0))

            if newCanvasList.count > 0 {
                Section("new") {
                    ForEach(newCanvasList, id: \.self) { canvas in
                        NavigationLink {
                            CanvasView(id: canvas.id)
                        } label: {
                            makeLabel(data: canvas)
                        }
                    }
                }
            }
            if canvasList.count > 0 {
                Section("canvas list") {
                    ForEach(canvasList, id: \.self) { canvas in
                        if canvas.deletedNow == false  {
                            NavigationLink {
                                CanvasView(id: canvas.id)
                            } label: {
                                makeLabel(data: canvas)
                            }
                        }
                    }
                }
            }
            if newCanvasList.count == 0 && canvasList.count == 0 {
                Text("empty list msg")
            }
            NavigationLink {
                MakeNewCanvasView()
            } label: {
                Text("make new canvas")
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
        
        .sheet(isPresented: $isSheet) {
            MakeNewCanvasView()
        }

    }
    
    func reload() {
        FirestoreHelper.getCanvasList { list, error in
            // 신규 켄버스 추가
            for item in list {
                newCanvasList.insert(item, at: 0)
            }
            
            removeDeleted()

        }
    }
    
    func removeDeleted() {
        for canvas in newCanvasList {
            if canvas.deletedNow {
                if let idx = newCanvasList.firstIndex(of: canvas) {
                    newCanvasList.remove(at: idx)
                }
            }
        }
        for canvas in canvasList {
            if canvas.deletedNow {
                if let idx = canvasList.firstIndex(of: canvas) {
                    canvasList.remove(at: idx)
                }
            }
        }

    }
    func loadData() {
#if !targetEnvironment(simulator)
        if canvasList.count == 0 {
            for model in Realm.shared.objects(CanvasModel.self) {
                if model.deleted == false {
                    canvasList.append(model.threadSafeModel)
                }
            }
        }
        FirestoreHelper.getCanvasList { list, error in
            for item in list {
                if item.deletedNow == false {
                    canvasList.insert(item, at: 0)
                }
            }
        }
#else
        print(canvasList.count)
#endif
    }
}

struct CanvasListView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            CanvasListView(canvasList: [
                .init(id: "aaaa", title: "김치", onwerId: "djskala",updateDt: 1010123, deleted: false , width : 32, height: 32, offsetX: 0, offsetY: 0),
                .init(id: "aaba", title: "김치", onwerId: "djskala",updateDt: 1032800, deleted: true, width : 32, height: 32, offsetX: 0, offsetY: 0),

            ])
        }
    }
}
