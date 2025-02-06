
import Foundation

class TJLabsResourceNetworkManager {
    static let shared = TJLabsResourceNetworkManager()
    
    private let commonSessions: [URLSession]
    private var commonSessionCount = 0
    
    private let pathSessions: [URLSession]
    private var pathSessionCount = 0
    
    private init() {
        self.commonSessions = TJLabsResourceNetworkManager.createSessionPool()
        self.pathSessions = TJLabsResourceNetworkManager.createSessionPool()
    }
    
    // MARK: - Helper Methods
    private static func createSessionPool() -> [URLSession] {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = TJLabsResourceNetworkConstants.TIMEOUT_VALUE_PUT
        config.timeoutIntervalForRequest = TJLabsResourceNetworkConstants.TIMEOUT_VALUE_PUT
        return (1...3).map { _ in URLSession(configuration: config) }
    }

    private func encodeJson<T: Encodable>(_ param: T) -> Data? {
        do {
            return try JSONEncoder().encode(param)
        } catch {
            print("Error encoding JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func makeRequest(url: String, method: String = "POST", body: Data?) -> URLRequest? {
        guard let url = URL(string: url) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        }
        return request
    }

    private func performRequest<T>(
        request: URLRequest,
        session: URLSession,
        input: T,
        completion: @escaping (Int, String, T) -> Void
    ) {
        session.dataTask(with: request) { data, response, error in
            let code = (response as? HTTPURLResponse)?.statusCode ?? 500

            // Handle errors
            if let error = error {
                let message = (error as? URLError)?.code == .timedOut ? "Timed out" : error.localizedDescription
                DispatchQueue.main.async {
                    completion(code, message, input)
                }
                return
            }

            // Validate response status code
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200..<300).contains(statusCode) else {
                let message = (response as? HTTPURLResponse)?.description ?? "Request failed"
                DispatchQueue.main.async {
                    completion(code, message, input)
                }
                return
            }

            // Successful response
            let resultData = String(data: data ?? Data(), encoding: .utf8) ?? ""
            DispatchQueue.main.async {
                completion(statusCode, resultData, input)
            }
        }.resume()
    }
    
    func postBuildingLevel(url: String, input: SectorIdInput, completion: @escaping (Int, String, SectorIdInput) -> Void) {
        guard let body = encodeJson(input),
              let request = makeRequest(url: url, body: body) else {
            DispatchQueue.main.async { completion(406, "Invalid URL or failed to encode JSON", input) }
            return
        }

        let session = commonSessions[commonSessionCount % commonSessions.count]
        commonSessionCount += 1
        performRequest(request: request, session: session, input: input, completion: completion)
    }
    
    func postPathPixel(url: String, input: SectorIdOsInput, completion: @escaping (Int, String, SectorIdOsInput) -> Void) {
        guard let body = encodeJson(input),
              let request = makeRequest(url: url, body: body) else {
            DispatchQueue.main.async { completion(406, "Invalid URL or failed to encode JSON", input) }
            return
        }

        let session = pathSessions[pathSessionCount % pathSessions.count]
        pathSessionCount += 1
        performRequest(request: request, session: session, input: input, completion: completion)
    }
    
    func postScaleOffset(url: String, input: SectorIdOsInput, completion: @escaping (Int, String, SectorIdOsInput) -> Void) {
        guard let body = encodeJson(input),
              let request = makeRequest(url: url, body: body) else {
            DispatchQueue.main.async { completion(406, "Invalid URL or failed to encode JSON", input) }
            return
        }

        let session = commonSessions[commonSessionCount % commonSessions.count]
        commonSessionCount += 1
        performRequest(request: request, session: session, input: input, completion: completion)
    }
}
