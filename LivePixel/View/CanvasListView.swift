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
    @State var canvasList:[CanvasModel.ThreadSafeModel] = []

    let disposeBag = DisposeBag()
    init(canvasList: [CanvasModel.ThreadSafeModel]) {
        self.canvasList = canvasList
    }
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
    
    var body: some View {
        Section("canvas list") {
            ForEach(canvasList, id: \.self) { canvas in
                HStack {
                    ProfileView(id: canvas.onwerId, editable: false)
                        .frame(width: 80)
                    VStack {
                        Text(canvas.title)
                        Text(canvas.updateDate.formatted(date: .long, time: .standard))
                    }
                }
            }
        }.onAppear {
            loadData()
        }
    }
    
    func loadData() {
#if !targetEnvironment(simulator)
        if canvasList.count == 0 {
            for model in Realm.shared.objects(CanvasModel.self) {
                canvasList.append(model.threadSafeModel)
            }
        }
        FirestoreHelper.getCanvasList { list, error in
            for item in list {
                canvasList.insert(item, at: 0)
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
                .init(id: "aaaa", title: "김치", onwerId: "djskala",updateDt: 1010123),
                .init(id: "aaba", title: "김치", onwerId: "djskala",updateDt: 1032800),

            ])
        }
    }
}
