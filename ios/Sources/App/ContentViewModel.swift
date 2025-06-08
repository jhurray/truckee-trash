import Foundation
import TruckeeTrashKit
import Combine
import NotificationsService

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
    @Published var testDate: Date? = nil {
        didSet {
            // Save test date to SharedUserDefaults for widget access
            SharedUserDefaults.debugTestDate = testDate
        }
    }
    @Published var isTestMode = false
    var currentDate: Date { testDate ?? Date() }
    var shouldReloadData: Bool = true
    #else
    var currentDate: Date { Date() }
    #endif
    
    private let apiClient = TruckeeTrashKit.shared.apiClient
    private var cancellables = Set<AnyCancellable>()
    
    @available(iOS 16.1, *)
    private var liveActivityService: LiveActivityService? = nil
    
    init() {
        #if DEBUG
        // Load test date from SharedUserDefaults if it exists
        if SharedUserDefaults.debugTestModeEnabled,
           let savedTestDate = SharedUserDefaults.debugTestDate {
            self.testDate = savedTestDate
            self.isTestMode = true
        }
        #endif
        
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
        let selectedPickupDay = SharedUserDefaults.selectedPickupDay
        
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
                    
                    // Update Live Activity if available
                    if #available(iOS 16.1, *) {
                        self?.liveActivityService?.handlePickupInfoUpdate(
                            pickupInfo: pickupInfo,
                            nextPickupDate: self?.nextPickupDate
                        )
                    }
                    
                case .failure(let error):
                    self?.pickupInfo = nil
                    self?.errorMessage = error.localizedDescription
                    
                    // End Live Activity on error
                    if #available(iOS 16.1, *) {
                        self?.liveActivityService?.endCurrentActivity()
                    }
                }
            }
        }
    }
    
    @available(iOS 16.1, *)
    func setLiveActivityService(_ service: LiveActivityService) {
        self.liveActivityService = service
    }
    
    #if DEBUG
    func setTestDate(_ date: Date) {
        testDate = date
        isTestMode = true
        loadPickupInfo()
    }
    
    func clearTestDate() {
        testDate = nil // This will trigger the didSet and clear UserDefaults
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
