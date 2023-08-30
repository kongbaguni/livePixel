//
//  SubjectListView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/30.
//

import SwiftUI
import RealmSwift

struct SubjectListView: View {
    
    @State var subjects:[SubjectModel.ThreadSafeModel] = []
    @State var alertMsg:Text? = nil {
        didSet {
            if alertMsg != nil {
                isAlert = true
            }
        }
    }
    @State var isAlert:Bool = false
    var body: some View {
        List {
            if subjects.count == 0 {
                Text("subject empty msg")
            } else {
                Section {
                    ForEach(subjects, id:\.self) { subject in
                        NavigationLink {
                            CanvasListView(subjectId: subject.id)
                        } label: {
                            Text(subject.title)
                        }
                    }
                }
            }
            
            NavigationLink {
                MakeSubjectView()
            } label: {
                Text("make subject")
            }
        }.onAppear {
            loadData()
        }
        .navigationTitle("subject list")
        .alert(isPresented: $isAlert) {
            .init(title: Text("alert"), message: alertMsg,dismissButton:.default(Text("confirm")))
        }
    }
    
    func loadData() {
        FirebaseFirestoreHelper.shared.getSubjects { error in
            subjects = Realm.shared.objects(SubjectModel.self).map { model in
                return model.threadSafeModel
            }
            if let err = error {
                alertMsg = Text("\(err.localizedDescription)")
            }
        }
    }
}

struct SubjectListView_Previews: PreviewProvider {
    static var previews: some View {
        SubjectListView()
    }
}
