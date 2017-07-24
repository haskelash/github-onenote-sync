//
//  Structs.swift
//  GitHubOneNoteSync
//
//  Created by Haskel Ash on 7/23/17.
//
//

import Foundation
import App

struct Notebook {
    var id: String
    var name: String
    var sectionGroups: [SectionGroup]
    var sections: [Section]
}

struct SectionGroup {
    static func from(_ data: [Node]) -> [SectionGroup] {
        return []
    }
}

struct Section {
    static func from(_ data: [Node]) -> [Section] {
        return []
    }
}
