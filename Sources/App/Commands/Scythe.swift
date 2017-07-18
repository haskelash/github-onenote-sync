//
//  Scythe.swift
//  GitHubOneNoteSync
//
//  Created by Haskel Ash on 7/16/17.
//
//

import Vapor
import Console
import Foundation

public final class Scythe: Command {
    public let id = "scythe"
    public let help = ["Collects all the users notes from the OneNote API and saves them locally."]
    public let console: ConsoleProtocol
    public init(console: ConsoleProtocol) {
        self.console = console
    }

    public func run(arguments: [String]) throws {
        console.print("Running Scythe")
        let semaphore = DispatchSemaphore(value: 0)
        var needsRefresh = false
        var request = URLRequest(url: URL(string: oneNoteEndpoint)!)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        session.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            if (response as! HTTPURLResponse).statusCode == 401 {
                needsRefresh = true
            } else {
                print("data: \(String(describing: data))")
                print("response: \(String(describing: response))")
                print("error: \(String(describing: error))")
                guard let data = data else { return }
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return }
                print("json: \(json)")
            }
        }.resume()
        let _ = semaphore.wait(timeout: 60)
        if needsRefresh {
            retry()
        }
        print("done")
    }

    private func retry() {
        console.print("Refreshing token")
        let semaphore = DispatchSemaphore(value: 0)
        var request = URLRequest(url: URL(string: tokenEndpoint)!)
        request.httpMethod = "POST"
        let body = "Content-Type=application/x-www-form-urlencoded"
            + "&grant_type=refresh_token"
            + "&client_id=\(clientId)"
            + "&client_secret=\(clientSecret)"
            + "&redirect_uri=\(redirectUri)"
            + "&refresh_token=\(refreshToken)"
        request.httpBody = body.data(using: .utf8)
        session.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            print("data: \(String(describing: data))")
            print("response: \(String(describing: response))")
            print("error: \(String(describing: error))")
            guard let data = data else { return }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return }
            print("json: \(json)")
        }.resume()
        let _ = semaphore.wait(timeout: 10*60)
    }
}

extension Scythe: ConfigInitializable {
    public convenience init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console: console)
    }
}
