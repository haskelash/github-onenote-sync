//
//  TokenRequests.swift
//  GitHubOneNoteSync
//
//  Created by Haskel Ash on 7/19/17.
//
//

import Foundation
import App

func refreshToken(drop: Droplet) -> String? {
    let request = Request(method: .post, uri: tokenEndpoint)
    request.headers = ["Content-Type": "application/x-www-form-urlencoded"]
    request.body = .init("grant_type=refresh_token"
        + "&client_id=\(clientId)"
        + "&client_secret=\(clientSecret)"
        + "&redirect_uri=\(redirectUri)"
        + "&refresh_token=\(refreshToken)")

    drop.console.print("Refreshing token...")
    let response = try? drop.client.respond(to: request)
    drop.console.print("Returned from refresh with response:")
    drop.console.print(response?.description ?? "Error")

    return response?.data["access_token"]?.string
}
