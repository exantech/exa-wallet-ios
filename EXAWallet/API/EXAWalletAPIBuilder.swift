//
// Created by Igor Efremov on 14/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation
import SwiftyJSON

enum HTTPMethod: String {
    case post, get, put, head
}

class EXAWalletAPIBuilder {
    let apiRoot = "api"
    let infoApi = "info"
    private let conf = ConfigurationSelector.shared.currentConfiguration

    func buildApiRequest(_ endPoint: String, method: HTTPMethod = .post, headers: [String: String]? = nil, payload: APIParam? = nil,
                         info: Bool = false, timeInterval: TimeInterval = 0) -> URLRequest? {
        guard let url = urlToApiEndPoint(endPoint, info: info, method: method, payload: payload) else { return nil }
        print("\tPrepare request url: \(url.absoluteString)")
        let req = buildRequest(url, method: method, headers: headers, params: payload)

        print("\tRequest: \(req)")
        if let theHeader = (headers?.values.compactMap{$0}) {
            print("\t\tHeader: \(theHeader)")
        }

        if .get != method {
            if let thePayload = payload?.json()?.description {
                print("\t\tPayload: \(thePayload)")
            }
        }

        return req
    }

    func urlToApiEndPoint(_ endPoint: String, info: Bool = false, method: HTTPMethod = .post, payload: APIParam? = nil) -> URL? {
        var uc = URLComponents()
        uc.scheme = conf.apiSecure ? "https" : "http"
        uc.host = conf.apiHost
        uc.port = conf.apiPort
        if .get == method {
            uc.query = payload?.queryString()
        }

        let parts = info ? ["/", apiRoot, conf.apiVersion.rawValue, infoApi, endPoint] : ["/", apiRoot, conf.apiVersion.rawValue, endPoint]
        uc.path = NSString.path(withComponents: parts)

        return uc.url
    }

    func buildRequest(_ url: URL, method: HTTPMethod, headers: [String: String]?, params: Jsonable?, timeInterval: TimeInterval = 0) -> URLRequest {
        var request = URLRequest(url: url)
        if timeInterval > 0 {
            request.timeoutInterval = timeInterval
        }

        switch method {
        case .get:
            noop()
        default:
            addParams(&request, params)
        }

        addHeaders(&request, headers: headers)
        addMethod(&request, method)

        return request
    }

    func buildSessionRequestHeaders(nonce: UInt64, signature: String) -> [String: String]? {
        guard signature.length > 0 else {
            print("Signature is empty")
            return nil
        }
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return nil }
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.metaInfo.uuid) else {
            print("Session Id isn't defined")
            return nil
        }

        return ["X-Session-Id": sessionId,
                   "X-Nonce": String(nonce),
                   "X-Signature": signature]
    }

    private func addHeaders(_ request: inout URLRequest, headers: [String: String]?) {
        guard let theHeaders = headers else { return }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        for field in theHeaders {
            request.addValue(field.value, forHTTPHeaderField: field.key)
        }
    }

    private func addMethod(_ request: inout URLRequest, _ method: HTTPMethod) {
        request.httpMethod = method.rawValue
    }

    private func addParams(_ request: inout URLRequest, _ params: Jsonable?) {
        guard let json = params?.json() else {
            return
        }

        request.httpBody = try? json.rawData()
    }
}
