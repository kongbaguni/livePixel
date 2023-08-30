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
    
    var body: some View {
        List {
                     
            ForEach(subjects, id:\.self) { subject in
                NavigationLink {
                    CanvasListView(subjectId: subject.id)
                } label: {
                    Text(subject.title)
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
    }
    
    func loadData() {
        subjects = Realm.shared.objects(SubjectModel.self).map { model in
            return model.threadSafeModel
        }
    }
}

struct SubjectListView_Previews: PreviewProvider {
    static var previews: some View {
        SubjectListView()
    }
}
