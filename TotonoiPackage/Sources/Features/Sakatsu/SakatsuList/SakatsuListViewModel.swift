import Foundation
import Combine
import SakatsuData

struct SakatsuListUiState {
    var isLoading: Bool
    var sakatsus: [Sakatsu]
    var sakatsuText: String?
}

@MainActor
final class SakatsuListViewModel<Repository: SakatsuRepository>: ObservableObject {
    @Published private(set) var uiState = SakatsuListUiState(
        isLoading: true,
        sakatsus: [],
        sakatsuText: nil
    )
    
    private let repository: Repository
    
    nonisolated init(repository: Repository = SakatsuUserDefaultsClient.shared) {
        self.repository = repository
        Task {
            await refreshSakatsus()
        }
    }
    
    private func refreshSakatsus() async {
        uiState.isLoading = true
        uiState.sakatsus = (try? await repository.sakatsus()) ?? [] // FIXME:
        uiState.isLoading = false
    }
}

// MARK: Event handler

extension SakatsuListViewModel {
    func onSakatsuSave() async {
        await refreshSakatsus()
    }
    
    func onEditButtonClick() {
        // TODO:
    }
    
    func onOutputSakatsuTextButtonClick(sakatsuIndex: Int) {
        let text = outputSakatsuText(sakatsu: uiState.sakatsus[sakatsuIndex])
        uiState.sakatsuText = text
    }
    
    func onDelete(at offsets: IndexSet) async throws {
        uiState.sakatsus.remove(atOffsets: offsets)
        try await repository.saveSakatsus(uiState.sakatsus)
    }
    
    private func outputSakatsuText(sakatsu: Sakatsu) -> String {
        var text = "\(sakatsu.saunaSets.count)セット行いました。"
        for saunaSets in sakatsu.saunaSets {
            text += "\n"
            if let saunaTime = saunaSets.sauna.time {
                text += "サウナ（\(saunaTime)分）"
            }
            if let coolBathTime = saunaSets.coolBath.time {
                text += "→水風呂（\(coolBathTime)秒）"
            }
            if let relaxationTime = saunaSets.relaxation.time {
                text += "→休憩（\(relaxationTime)分）"
            }
        }
        return text
    }
}
