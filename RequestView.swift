
//
//  RequestView.swift
//  HMS_admin_Demo_02
//
//  Created by Sameer Verma on 04/07/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct Request: Identifiable {
    var id = UUID()
    var firestoreId: String
    var name: String
    var idNumber: String
    var department: String
    var reason: String
    var fromDate: Date
    var toDate: Date
    var status: Status = .pending

    enum Status: String {
        case pending, approved, rejected
    }
}

struct RequestView: View {
    @State private var searchText = ""
    @State private var selectedSegment = 0
    @State private var requests: [Request] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var filteredRequests: [Request] {
        let list = selectedSegment == 0 ? requests.filter { $0.status == .pending } : requests.filter { $0.status != .pending }
        if searchText.isEmpty {
            return list
        } else {
            return list.filter { $0.name.lowercased().contains(searchText.lowercased()) || $0.department.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(UIColor.opaqueSeparator))
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray4).opacity(0.5))
                    .cornerRadius(8)
                }
                .padding(.horizontal)

                Picker("Requests", selection: $selectedSegment) {
                    Text("Pending").tag(0)
                    Text("Status").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedSegment == 0 {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
                            ForEach(filteredRequests) { request in
                                RequestBoxView(request: request, approveAction: {
                                    updateRequestStatus(request, status: .approved)
                                }, disapproveAction: {
                                    updateRequestStatus(request, status: .rejected)
                                })
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        fetchRequests()
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
                            ForEach(filteredRequests) { request in
                                ApprovedDoctorView(doctor: request)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        fetchRequests()
                    }
                }
            }
            .background(Color("LightColor").opacity(0.3).edgesIgnoringSafeArea(.all))
            .onAppear {
                fetchRequests()
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationTitle("Leave Requests")
        }
    }

    private func updateRequestStatus(_ request: Request, status: Request.Status) {
        FirestoreService.shared.updateRequestStatus(requestId: request.firestoreId, status: status.rawValue) { error in
            if let error = error {
                alertMessage = "Failed to update request status: \(error.localizedDescription)"
                showingAlert = true
            } else {
                if let index = requests.firstIndex(where: { $0.id == request.id }) {
                    requests[index].status = status
                    selectedSegment = 1
                }
            }
        }
    }

    private func fetchRequests() {
        FirestoreService.shared.fetchRequests { fetchedRequests, error in
            if let error = error {
                alertMessage = "Failed to fetch requests: \(error.localizedDescription)"
                showingAlert = true
            } else if let fetchedRequests = fetchedRequests {
                requests = fetchedRequests
            }
        }
    }
}

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    func fetchRequests(completion: @escaping ([Request]?, Error?) -> Void) {
        db.collection("requests").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
            } else {
                var requests = [Request]()
                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    let request = Request(
                        id: UUID(),
                        firestoreId: document.documentID,
                        name: data["doctorName"] as? String ?? "",
                        idNumber: data["doctorId"] as? String ?? "",
                        department: data["department"] as? String ?? "",
                        reason: data["reason"] as? String ?? "",
                        fromDate: (data["fromDate"] as? Timestamp)?.dateValue() ?? Date(),
                        toDate: (data["toDate"] as? Timestamp)?.dateValue() ?? Date(),
                        status: Request.Status(rawValue: data["status"] as? String ?? "pending") ?? .pending
                    )
                    requests.append(request)
                }
                completion(requests, nil)
            }
        }
    }

    func updateRequestStatus(requestId: String, status: String, completion: @escaping (Error?) -> Void) {
        db.collection("requests").document(requestId).updateData(["status": status]) { error in
            completion(error)
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
            Text("Department: \(request.department)")
                .fontWeight(.bold)

            Text("Reason: \(request.reason)")
            Text("From: \(request.fromDate.formatted()) - \(request.toDate.formatted())")

            HStack {
                Spacer()
                Button(action: approveAction) {
                    Text("Approve")
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.horizontal)

                Button(action: disapproveAction) {
                    Text("Reject")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
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
                if doctor.status == .approved {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.green)
                } else if doctor.status == .rejected {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.red)
                }
            }
            .padding(.bottom, 10)

            Text(doctor.name)
                .fontWeight(.bold)
            Text("Department: \(doctor.department)")
                .fontWeight(.bold)

            Text("Reason: \(doctor.reason)")
            Text("From: \(doctor.fromDate.formatted()) - \(doctor.toDate.formatted())")
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
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

extension Date {
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView()
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
    }
}
