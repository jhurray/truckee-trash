import Foundation
import TruckeeTrashKit
import Combine

@MainActor
class ContentViewModel: ObservableObject {
    @Published var pickupInfo: DayPickupInfo?
    @Published var nextPickupDate: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = TruckeeTrashKit.shared.apiClient
    private var cancellables = Set<AnyCancellable>()
    
    func loadPickupInfo() {
        isLoading = true
        errorMessage = nil
        
        // Get user's selected pickup day (default to Friday if not set)
        let selectedPickupDay = UserDefaults.standard.object(forKey: "selectedPickupDay") as? Int ?? 5 // Friday
        
        // Calculate next occurrence of selected pickup day
        let currentDate = apiClient.getCurrentTruckeeDate()
        let nextPickupDate = currentDate.nextOccurrence(of: selectedPickupDay)
        self.nextPickupDate = nextPickupDate
        
        // Fetch pickup info for that date
        apiClient.fetchDayPickupType(for: nextPickupDate) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let pickupInfo):
                    self?.pickupInfo = pickupInfo
                    self?.errorMessage = nil
                case .failure(let error):
                    self?.pickupInfo = nil
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}