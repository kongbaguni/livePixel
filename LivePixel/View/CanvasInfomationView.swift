//
//  CanvasInfomationView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/31.
//

import SwiftUI
import RealmSwift

struct CanvasInfomationView: View {
    let id:String
    @State var title:String = ""
    @State var dotes:Set<DoteModel.ThreadSafeModel> = []
    init(id: String, title: String, dotes: Set<DoteModel.ThreadSafeModel>) {
        self.id = id
        self.title = title
        self.dotes = dotes
    }

    init(id: String) {
        self.id = id
        loadData()
    }
    
    var body: some View {
        List {
            Section("log") {
                ForEach(dotes.sorted(by: { a, b in
                    return a.date > b.date
                }), id:\.self) { dote in
                    HStack {
                        dote.color.frame(width:50, height: 50)
                        VStack {
                            HStack {
                                Text("x").foregroundColor(.secondary)
                                Text("\(dote.x)").foregroundColor(.primary)
                                Text("y").foregroundColor(.secondary)
                                Text("\(dote.y)").foregroundColor(.primary)
                                Text("size").foregroundColor(.secondary)
                                Text("\(dote.size + 1)").foregroundColor(.primary)
                                Text("brush").foregroundColor(.secondary)
                                Text("\(dote.drawType)").foregroundColor(.primary)
                                Spacer()
                            }
                            HStack {
                                Text("regDate").foregroundColor(.secondary)
                                
                                Text(dote.date.formatted(date: .long, time: .shortened))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                        Spacer()
                        ProfileView(id: dote.ownerId, editable: false).frame(width:150)
                    }
                }
            }
        }
        .navigationTitle(title)
        .onAppear {
            loadData()
        }
             
    }
    
    func loadData() {
        title = Realm.shared.object(ofType: CanvasModel.self, forPrimaryKey: id)?.title ?? ""
        for item in Realm.shared.objects(DoteModel.self).filter("canvasId = %@", id) {
            dotes.insert(item.threadSafeModel)
        }
    }
        
}

struct CanvasInfomationView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasInfomationView(id: "test", title:"test", dotes: Set([
            .init(id: "", x: 0, y: 0, canvasId: "", red: 0, green: 1, blue: 0, opacity: 1, date: Date(), ownerId: "asd", size: 0, drawType: "circle")
            
        ]))
    }
}
