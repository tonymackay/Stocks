//
//  StocksClient.swift
//  Stocks
//
//  Created by Tony Mackay on 15/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import Foundation

struct StockDTO: Codable {
    let description: String
    let symbol: String
}

struct QuoteDTO: Codable {
    let symbol: String
    let currency: String
    let price: Decimal
    let previousPrice: Decimal
}

class StocksClient {
    enum Endpoints {
        static let base = "https://stocks.viewmodel.net"
        
        case search(query: String)
        case quote(symbol: [String])
        
        var stringValue: String {
            switch self {
            case .search(let query):
                return Endpoints.base + "/search/\(query)"
            case .quote(let symbol):
                var urlComponents = URLComponents(string: Endpoints.base + "/quote")
                var urlQueryItems = [URLQueryItem]()
                for symbolElement in symbol {
                    urlQueryItems.append(URLQueryItem(name: "symbol", value: symbolElement))
                }
                urlComponents?.queryItems = urlQueryItems
                let result = urlComponents?.url!
                return result?.absoluteString ?? ""
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    @discardableResult
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            print(String(data: data, encoding: .utf8) ?? "")
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    class func search(query: String, completion: @escaping ([StockDTO], Error?) -> Void) {
        let url = Endpoints.search(query: query).url
        taskForGETRequest(url: url, responseType: [StockDTO].self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion([StockDTO](), error)
            }
        }
    }
    
    class func quote(symbol: [String], completion: @escaping ([QuoteDTO], Error?) -> Void) {
        let url = Endpoints.quote(symbol: symbol).url
        taskForGETRequest(url: url, responseType: [QuoteDTO].self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion([QuoteDTO](), error)
            }
        }
    }
}
