//
//  PricingView.swift
//  HMS_admin_Demo_02
//
//  Created by Sameer Verma on 04/07/24.
//

import SwiftUI
import FirebaseFirestore



struct MedicalTest: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var price: Double

    func toDictionary() -> [String: Any] {
        return ["id": id.uuidString, "name": name, "price": price]
    }
}

struct PricingView: View {
    @State private var medicalTests = [MedicalTest]()
    @State private var showAddTestView = false
    @State private var searchText = ""
    @State private var selectedTest: MedicalTest?

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Test Fee")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                    Button(action: {
                        showAddTestView = true
                    }) {
                        Text("+ Add Test")
                            .padding()
                            .background(Color.CustomRed)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                HStack {
                    TextField("Search", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: UIScreen.main.bounds.width / 2)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 0) {
                    // Heading row
                    HStack {
                        Text("Serial Number")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Test")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Price")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.2))
                    
                    Divider()
                    
                    // Test rows
                    List {
                        ForEach(Array(filteredTests.enumerated()), id: \.element.id) { index, test in
                            Button(action: {
                                selectedTest = test
                            }) {
                                HStack {
                                    Text("\(index + 1)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(test.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("\(test.price, specifier: "%.2f")")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                .background(Color(hex: "#EFBAB1").opacity(0.3))
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding()
            } .background(Color(hex: "#EFBAB1").opacity(0.3))
            .sheet(isPresented: $showAddTestView) {
                AddTestView(onSave: fetchData)
            }
            .sheet(item: $selectedTest) { test in
                EditTestView(test: test, onSave: fetchData)
            }
        }
        .onAppear {
            fetchData()
        }
    }
    
    var filteredTests: [MedicalTest] {
        if searchText.isEmpty {
            return medicalTests
        } else {
            return medicalTests.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func fetchData() {
        let db = Firestore.firestore()
        db.collection("LabTestPrices").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                medicalTests = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    let id = UUID(uuidString: data["id"] as? String ?? "") ?? UUID()
                    let name = data["name"] as? String ?? ""
                    let price = data["price"] as? Double ?? 0.0
                    return MedicalTest(id: id, name: name, price: price)
                } ?? []
            }
        }
    }
}
extension Color {
   static let CustomRed = Color(red: 225/255, green: 101/255, blue: 70/255)}
#Preview {
    PatientView()
}
