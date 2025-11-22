import Foundation

enum BackendConfiguration {
    static var baseURL: URL {
        if let rawValue = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           let url = URL(string: rawValue) {
            return url
        }
        return URL(string: "http://localhost:5270")!
    }
}
