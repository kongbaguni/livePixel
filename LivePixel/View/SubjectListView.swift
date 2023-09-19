//
//  SubjectListView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/30.
//

import SwiftUI
import RealmSwift
import RxSwift
import RxRealm

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
    let disposeBag = DisposeBag()
    
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
            requestServerData()
            Observable.collection(from: Realm.shared.objects(SubjectModel.self))
                .subscribe { [self] event in
                    DispatchQueue.main.async {
                        switch event {
                        case .next(let result) :
                            self.subjects = result.map { model in
                                print(model.title)
                                return model.threadSafeModel
                            }
                        case .error(let error) :
                            print(error.localizedDescription)
                        case .completed:
                            break
                        }

                    }
                }
                .disposed(by: disposeBag)

        }
        .navigationTitle("subject list")
        .alert(isPresented: $isAlert) {
            .init(title: Text("alert"), message: alertMsg,dismissButton:.default(Text("confirm")))
        }
    }
    
    func requestServerData() {
        FirebaseFirestoreHelper.shared.getSubjects { error in
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
