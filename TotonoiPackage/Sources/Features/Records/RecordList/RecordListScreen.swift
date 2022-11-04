import SwiftUI
import RecordsData

public struct RecordListScreen: View {
    @StateObject private var viewModel = RecordListViewModel()
    
    @State private var isShowingSheet = false
    
    public var body: some View {
        NavigationView {
            RecordListView(
                sakatsus: viewModel.uiState.sakatsus,
                onDelete: { offsets in
                    viewModel.onDelete(at: offsets)
                }
            )
            .navigationTitle("サ活一覧")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $isShowingSheet) {
                        NavigationView {
                            RecordInputScreen(onSakatsuSave: {
                                isShowingSheet = false
                                viewModel.onSakatsuSave()
                            })
                        }
                    }
                }
            }
        }
    }
    
    public init() {}
}

struct RecordListScreen_Previews: PreviewProvider {
    static var previews: some View {
        RecordListScreen()
    }
}

private struct RecordListView: View {
    let sakatsus: [Sakatsu]
    let onDelete: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(sakatsus) { sakatsu in
                RecordRowView(sakatsu: sakatsu)
                    .padding(.vertical)
            }
            .onDelete { offsets in
                onDelete(offsets)
            }
        }
    }
}

struct RecordListView_Previews: PreviewProvider {
    static var previews: some View {
        RecordListView(
            sakatsus: [Sakatsu.preview],
            onDelete: { offsets in
                print("onDelete")
            }
        )
    }
}
