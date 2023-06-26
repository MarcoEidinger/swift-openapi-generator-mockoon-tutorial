//
//  ContentView.swift
//  DemoApp
//
//  Created by Marco Eidinger on 6/17/23.
//

import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession

struct ContentView: View {
    
    let client: Client
    @State var model: Components.Schemas.inline_response_200?
    @State var error: String?
    
    init() {
        self.client = Client(
            serverURL: URL(string: "http://localhost:3000")!,
            transport: URLSessionTransport()
        )
    }
    
    var body: some View {
        VStack {
            if let error = error {
                Text(error)
            }
            if let model = self.model {
                Text("Hi, your IP address is \(model.ip_address ?? "") and you are located in \(model.city ?? ""), a city in the wonderful country \(model.country ?? "")")
            }
            Button("Refresh") {
                self.error = nil
                
                Task {
                    try? await fetchData()
                }
            }
        }
        .padding()
        .task {
            try? await fetchData()
        }
    }
    
    func fetchData() async throws {
        let response = try await client.get_v1_(.init(query: .init(api_key: "fakeApiKey", ip_address:  "73.158.231.173")))
        switch response {
        case .ok(let okresponse):
            switch okresponse.body {
            case .json(let result):
                self.model = result
                self.error = nil
            }
        case .undocumented(statusCode: let statusCode, let undocumentedPayload):
            self.model = nil
            self.error = "Undocumented response \(statusCode) from server: \(undocumentedPayload)."
        }
    }
//
//    func getPublicIPAddress() -> String {
//        let address = try? String(contentsOf: URL(string: "https://api.ipify.org")!, encoding: .utf8)
//        return address ?? "ERROR"
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
