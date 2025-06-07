import Foundation
import TruckeeTrashKit
import Combine

extension Notification.Name {
    static let pickupDayChanged = Notification.Name("pickupDayChanged")
}

@MainActor
class ContentViewModel: ObservableObject {
    @Published var pickupInfo: DayPickupInfo?
    @Published var nextPickupDate: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    #if DEBUG
    @Published var testDate: Date? = nil
    @Published var isTestMode = false
    var currentDate: Date { testDate ?? Date() }
    var shouldReloadData: Bool = true
    #else
    var currentDate: Date { Date() }
    #endif
    
    private let apiClient = TruckeeTrashKit.shared.apiClient
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Listen for pickup day changes
        NotificationCenter.default.publisher(for: .pickupDayChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadPickupInfo()
            }
            .store(in: &cancellables)
    }
    
    func loadPickupInfo() {
        #if DEBUG
        guard shouldReloadData else { return }
        #endif
        
        isLoading = true
        errorMessage = nil
        
        // Get user's selected pickup day (default to Friday if not set)
        let selectedPickupDay = UserDefaults.standard.object(forKey: "selectedPickupDay") as? Int ?? 5 // Friday
        
        // Calculate next occurrence of selected pickup day
        #if DEBUG
        let currentDate = testDate ?? apiClient.getCurrentTruckeeDate()
        #else
        let currentDate = apiClient.getCurrentTruckeeDate()
        #endif
        
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
    
    #if DEBUG
    func setTestDate(_ date: Date) {
        testDate = date
        isTestMode = true
        loadPickupInfo()
    }
    
    func clearTestDate() {
        testDate = nil
        isTestMode = false
        loadPickupInfo()
    }

    init(pickupInfo: DayPickupInfo?, isLoading: Bool = false, errorMessage: String? = nil) {
        self.pickupInfo = pickupInfo
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.shouldReloadData = false

        if let pickupInfo = pickupInfo {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
            self.nextPickupDate = formatter.date(from: pickupInfo.date)
        }
    }
    #endif
}
