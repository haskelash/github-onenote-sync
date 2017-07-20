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
let request = Request(method: .get, uri: "https://www.onenote.com/api/v1.0/me/notes/notebooks")
request.headers = ["Authorization": "Bearer \(token)"]
request.body = .init("")
drop.console.print("Fetching notebooks...")
let response = try drop.client.respond(to: request)
drop.console.print("Returned from fetching with response:")
drop.console.print(response.description)

let ids = response.data["value", "id"]?.array ?? []
let names = response.data["value", "name"]?.array ?? []
let zipped = zip(ids, names).map{($0.0.string!, $0.1.string!)}
drop.console.print(zipped.description)
