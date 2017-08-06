//
//  Structs.swift
//  GitHubOneNoteSync
//
//  Created by Haskel Ash on 7/23/17.
//
//

import Foundation
import App

class Notebook {
    let id: String
    let name: String
    let sectionGroups: [SectionGroup]
    let sections: [Section]

    init(id: String, name: String, sectionGroups: [SectionGroup], sections: [Section]) {
        self.id = id; self.name = name; self.sectionGroups = sectionGroups; self.sections = sections
    }
}

class SectionGroup {
    let id: String
    let name: String
    let sectionGroups: [SectionGroup]
    let sections: [Section]

    init(node: Node) {
        let id = node["id"]!.string!

        let request = Request(method: .get, uri: "https://www.onenote.com/api/v1.0/me/notes/sectiongroups/\(id)?"
            + "select=id,name,sectionGroups,sections&expand=sectionGroups,sections")
        request.headers = ["Authorization": "Bearer \(token)"]
        request.body = .init("")
        drop.console.print("Fetching sectionGroup \(id)...")
        guard let response = try? drop.client.respond(to: request) else { fatalError("Error fetching section group \(id)") }
        drop.console.print("Returned from fetching with response:")
        drop.console.print(response.description)

        self.id = id
        self.name = node["name"]!.string!
        self.sectionGroups = response.data["sectionGroups"]!.array!.map{SectionGroup(node: $0)}
        self.sections = response.data["sections"]!.array!.map{Section(node: $0)}
    }
}

class Section {
    let id: String
    let name: String
    let pages: [Page]

    init(node: Node) {
        let id = node["id"]!.string!

        let request = Request(method: .get, uri: "https://www.onenote.com/api/v1.0/me/notes/sections/\(id)/pages?"
            + "select=id,title,createdTime,lastModifiedTime")
        request.headers = ["Authorization": "Bearer \(token)"]
        request.body = .init("")
        drop.console.print("Fetching pages in section \(id)...")
        guard let response = try? drop.client.respond(to: request) else { fatalError("Error fetching pages in section \(id)") }
        drop.console.print("Returned from fetching with response:")
        drop.console.print(response.description)

        self.id = id
        self.name = node["name"]!.string!
        self.pages = response.data["value"]!.array!.map{Page(node: $0)}
    }
}

class Page {
    let id: String
    let title: String
    let content: String

    init(node: Node) {
        let id = node["id"]!.string!

        let request = Request(method: .get, uri: "https://www.onenote.com/api/v1.0/me/notes/pages/\(id)/content?"
            + "includeIDs=true&preAuthenticated=true")
        request.headers = ["Authorization": "Bearer \(token)"]
        request.body = .init("")
        drop.console.print("Fetching page \(id)...")
        guard let response = try? drop.client.respond(to: request) else { fatalError("Error fetching page \(id)") }
        drop.console.print("Returned from fetching with response:")
        drop.console.print(response.description)

        self.id = id
        self.title = node["title"]!.string!
        self.content = response.body.bytes!.makeString()
    }
}
