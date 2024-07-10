//
//  RequestView.swift
//  HMS_admin_Demo_02
//
//  Created by Sameer Verma on 04/07/24.
//

import SwiftUI

// Extension to use hex color values


struct Request: Identifiable {
    var id = UUID()
    var name: String
    var idNumber: String
    var department: String
    var reason: String
    var fromDate: String
    var toDate: String
}

struct RequestView: View {
    @State private var searchText = ""
    @State private var selectedSegment = 0
    @State private var requests = [
        Request(name: "Dr. Sameer Verma", idNumber: "123", department: "Cardiology", reason: "Leave", fromDate: "24.6.2024", toDate: "26.6.2024"),
        Request(name: "Dr. John Doe", idNumber: "456", department: "Neurology", reason: "Conference", fromDate: "1.7.2024", toDate: "3.7.2024"),
        Request(name: "Dr. Jane Smith", idNumber: "789", department: "Pediatrics", reason: "Vacation", fromDate: "15.8.2024", toDate: "20.8.2024")
    ]
    @State private var approvedDoctors: [Request] = []

    var filteredRequests: [Request] {
        if searchText.isEmpty {
            return selectedSegment == 0 ? requests : approvedDoctors
        } else {
            return (selectedSegment == 0 ? requests : approvedDoctors).filter { $0.name.lowercased().contains(searchText.lowercased()) || $0.department.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("Request")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            .padding()

            SearchBar(text: $searchText)
                .padding(.horizontal)

            Picker("Requests", selection: $selectedSegment) {
                Text("Pending").tag(0)
                Text("Approved").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedSegment == 0 {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
                        ForEach(filteredRequests) { request in
                            RequestBoxView(request: request, approveAction: {
                                approveRequest(request)
                            }, disapproveAction: {
                                disapproveRequest(request)
                            })
                        }
                    }
                    .padding()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
                        ForEach(filteredRequests) { doctor in
                            ApprovedDoctorView(doctor: doctor)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color(hex: "#EFBAB1").opacity(0.3).edgesIgnoringSafeArea(.all))
    }

    private func approveRequest(_ request: Request) {
        if let index = requests.firstIndex(where: { $0.id == request.id }) {
            let approvedRequest = requests.remove(at: index)
            approvedDoctors.append(approvedRequest)
        }
    }

    private func disapproveRequest(_ request: Request) {
        if let index = requests.firstIndex(where: { $0.id == request.id }) {
            requests.remove(at: index)
        }
    }
}

struct RequestBoxView: View {
    var request: Request
    var approveAction: () -> Void
    var disapproveAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.bottom, 10)
            
            Text(request.name)
                .fontWeight(.bold)
            Text("ID: \(request.idNumber)")
                .fontWeight(.bold)
            Text("Department: \(request.department)")
                .fontWeight(.bold)
            
            Text("Reason: \(request.reason)")
            Text("From: \(request.fromDate) - \(request.toDate)")
            
            HStack {
                Spacer()
                Button(action: approveAction) {
                    Text("Approve")
                        .foregroundColor(.white)
                        .frame(width: 100, height: 40)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                Button(action: disapproveAction) {
                    Text("Reject")
                        .foregroundColor(.white)
                        .frame(width: 100, height: 40)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct ApprovedDoctorView: View {
    var doctor: Request

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.green)
            }
            .padding(.bottom, 10)
            
            Text(doctor.name)
                .fontWeight(.bold)
            Text("ID: \(doctor.idNumber)")
                .fontWeight(.bold)
            Text("Department: \(doctor.department)")
                .fontWeight(.bold)
            
            Text("Reason: \(doctor.reason)")
            Text("From: \(doctor.fromDate) - \(doctor.toDate)")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search"
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}


