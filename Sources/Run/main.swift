import App

/// We have isolated all of our App's logic into
/// the App module because it makes our app
/// more testable.
///
/// In general, the executable portion of our App
/// shouldn't include much more code than is presented
/// here.
///
/// We simply initialize our Droplet, optionally
/// passing in values if necessary
/// Then, we pass it to our App's setup function
/// this should setup all the routes and special
/// features of our app
///
/// .run() runs the Droplet's commands, 
/// if no command is given, it will default to "serve"
let config = try Config()
try config.setup()
//config.addConfigurable(command: Scythe.init, name: "scythe")

let drop = try Droplet(config)
try drop.setup()

let token = refreshToken(drop: drop) ?? ""
let request = Request(method: .get, uri: "https://www.onenote.com/api/v1.0/me/notes/notebooks?expand=sectionGroups,sections")
request.headers = ["Authorization": "Bearer \(token)"]
request.body = .init("")
drop.console.print("Fetching notebooks...")
let response = try drop.client.respond(to: request)
drop.console.print("Returned from fetching with response:")
drop.console.print(response.description)

var notebooks = [Notebook]()
let notebooksData = response.data["value"]?.array ?? []
for notebookData in notebooksData {
    let id = notebookData["id"]!.string!
    let name = notebookData["name"]!.string!
    let sectionGroupsData = notebookData["sectionGroups"]!.array!
    let sectionsData = notebookData ["sections"]!.array!

    let notebook = Notebook(id: id,
                            name: name,
                            sectionGroups: SectionGroup.from(sectionGroupsData),
                            sections: Section.from(sectionsData))
    notebooks.append(notebook)
}
