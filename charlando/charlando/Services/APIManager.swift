//
//  ConfigService.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 10/11/2023.
//

import Foundation

enum ResultError: Error {
    case generalError(Error?)
    case apiError(ApiError?)
}

class APIManager {
    static let shared = APIManager()
    let decoder = JSONDecoder()
    
    private var token: String = ""
    
    private let baseURL = URL(string: BASE_URL)!
    private var defaultHeaders: [String: String] {
        return ["Content-Type": "application/json", "Authorization": "Bearer \(self.token)"]
    }
    
    func performRequest(
        endpoint: String,
        method: String,
        body: Data? = nil,
        params: [URLQueryItem]? = nil,
        retries: Int = 5
    ) async throws -> Data {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        components.path = components.path + endpoint
        
        // Set params
        if (params != nil) {
            components.queryItems = params
        }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        
        // Set body
        if (body != nil) {
            request.httpBody = body
        }
        
        // Set default headers
        defaultHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let timeoutInterval: TimeInterval = 20
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = timeoutInterval
        sessionConfig.timeoutIntervalForRequest = timeoutInterval
        
        let session = URLSession(configuration: sessionConfig)
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if ((400..<499).contains(httpResponse.statusCode) && retries > 0) {
                return try await performRequest(endpoint: endpoint, method: method, body: body, params: params, retries: retries - 1)
            }
            try ErrorHandler.shared.errorHandler(httpResponse: httpResponse, data: data)
        }
        
        return data
    }
    
    func performRequest(
        endpoint: String,
        multipart: MultipartRequest
    ) async throws -> Data {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        request.setValue(multipart.httpContentTypeHeadeValue, forHTTPHeaderField: "Content-Type")
        request.httpBody = multipart.httpBody
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            try ErrorHandler.shared.errorHandler(httpResponse: httpResponse, data: data)
        }
        
        return data
    }
}

extension APIManager {
    static var language = "en"
    
    func getTokenFromKeyChainManager() -> Token? {
        guard let data = KeyChainManager.get(
            service: SERVICE_NAME,
            account: ACCOUNT_NAME
        ) else {
            return nil
        }
        
        let token = try? decoder.decode(Token.self, from: data)
        return token
    }
    
    func getToken() -> String {
        return self.token
    }
    
    func setToken(token: String) {
        if self.token == "" {
            self.token = token
        }
    }
    
    func removeToken() {
        self.token = ""
    }
    
    func getNewAccessToken() async {
        if let token = getTokenFromKeyChainManager() {
            let endpoint = GET_NEW_ACCESS_TOKEN_ENDPOINT
            let body = token.refreshToken.data(using: .utf8)
            do {
                let newAccessTokenData = try await performRequest(endpoint: endpoint, method: "POST", body: body)
                guard let newToken = String(data: newAccessTokenData, encoding: .utf8) else { return }
                guard let tokenData = Token(refreshToken: token.refreshToken, accessToken: newToken).asData() else { return }
                try KeyChainManager.save(service: SERVICE_NAME, account: ACCOUNT_NAME, data: tokenData)
                removeToken()
                setToken(token: newToken)
            } catch {
                
            }
        }
    }
    
    func removeAll() {
        let coreDataProvider = CoreDataProvider.shared
        let context = coreDataProvider.newContext
        APIManager.shared.removeToken()
        do {
            try KeyChainManager.save(
                service: SERVICE_NAME,
                account: ACCOUNT_NAME,
                data: "".data(using: .utf8)!
            )
            
            try coreDataProvider.deleteAll(entityName: "Channel", in: context)
            try coreDataProvider.deleteAll(entityName: "Message", in: context)
            try coreDataProvider.deleteAll(entityName: "Event", in: context)
            try coreDataProvider.deleteAll(entityName: "User", in: context)
            try coreDataProvider.deleteAll(entityName: "Owner", in: context)
            try coreDataProvider.deleteAll(entityName: "LinkPreview", in: context)
            try coreDataProvider.deleteAll(entityName: "UserDetail", in: context)
            ImageCache.shared.clearCache()
            SocketIOManager.shared.disconnect()
        } catch {
            
        }
    }
}

class ErrorHandler {
    static let shared = ErrorHandler()
    let apiManager: APIManager = APIManager.shared
    
    func errorHandler(httpResponse: HTTPURLResponse, data: Data) throws {
        switch httpResponse.statusCode {
        case 400..<499:
            let error = try JSONDecoder().decode(ApiError.self, from: data)
            unauthorizedHandler(error: error)
            throw ResultError.apiError(error)
        default:
            break
        }
    }
    
    private func unauthorizedHandler(error: ApiError) {
        if (error.message == "Expired JWT token!" && error.path != EXTENSION_URL + GET_NEW_ACCESS_TOKEN_ENDPOINT) {
            Task { await apiManager.getNewAccessToken() }
            return
        }
        
        if (error.status == 401 && error.path != EXTENSION_URL + LOGIN_ENDPOINT_ENDPOINT) {
            apiManager.removeAll()
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }
    }
}
