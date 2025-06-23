import Foundation

open class ApiClient {
    private let baseURL: String
    private let session: URLSession
    
    // Truckee timezone for date formatting
    private let truckeeTimeZone = TimeZone(identifier: "America/Los_Angeles")!
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = truckeeTimeZone
        return formatter
    }()
    
    public init(baseURL: String = "https://truckee-trash.vercel.app") {
        self.baseURL = baseURL
        self.session = URLSession.shared
    }
    
    /// Get the current date in Truckee timezone (respects debug test date)
    open func getCurrentTruckeeDate() -> Date {
        #if DEBUG
        // Use debug test date if available
        let now = DebugTestDateHelper.getCurrentDate()
        #else
        let now = Date()
        #endif
        
        let calendar = Calendar.current
        var components = calendar.dateComponents(in: truckeeTimeZone, from: now)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.nanosecond = 0
        return calendar.date(from: components) ?? now
    }
    
    // MARK: - Public API Methods
    
    open func fetchDayPickupType(for date: Date, completion: @escaping (Result<DayPickupInfo, ApiError>) -> Void) {
        let dateString = dateFormatter.string(from: date)
        fetchDayPickupType(for: dateString, completion: completion)
    }
    
    public func fetchDayPickupType(for dateString: String, completion: @escaping (Result<DayPickupInfo, ApiError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/pickup-type?date=\(dateString)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        performRequest(url: url, completion: completion)
    }
    
    public func fetchRelevantWeekStatus(currentDate: Date, completion: @escaping (Result<RelevantWeekStatusInfo, ApiError>) -> Void) {
        let dateString = dateFormatter.string(from: currentDate)
        fetchRelevantWeekStatus(currentDateString: dateString, completion: completion)
    }
    
    public func fetchRelevantWeekStatus(currentDateString: String, completion: @escaping (Result<RelevantWeekStatusInfo, ApiError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/relevant-week-pickup-status?currentDate=\(currentDateString)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        performRequest(url: url, completion: completion)
    }
    
    // MARK: - Private Methods
    
    private func performRequest<T: Codable>(url: URL, completion: @escaping (Result<T, ApiError>) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                // Check for server errors
                guard 200...299 ~= httpResponse.statusCode else {
                    let errorMessage = String(data: data, encoding: .utf8)
                    completion(.failure(.serverError(httpResponse.statusCode, errorMessage)))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            }
        }
        
        task.resume()
    }
}

// MARK: - Convenience Extensions

extension ApiClient {
    /// Format a date as YYYY-MM-DD string in Truckee timezone
    public func formatDateForAPI(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    /// Parse a YYYY-MM-DD string as Date in Truckee timezone
    public func parseDateFromAPI(_ dateString: String) -> Date? {
        return dateFormatter.date(from: dateString)
    }
}