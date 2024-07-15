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
                        .fontWeight(.bold)
                    Spacer()
                    
                }.padding(.top)
                .padding(.leading)
                
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color(.systemGray4).opacity(0.5))
                    .cornerRadius(8)
//                    .frame(maxWidth: .infinity,alignment: .leading)
 
                    
                    Button(action: {
                        showAddTestView = true
                    }) {
                        Text("+ Add Test")
                            .padding()
                            .background(Color(hex: "#E1654A"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }.padding(.leading)
                .padding(.horizontal)
                
               
                VStack(alignment: .leading, spacing: 0) {
                    // Heading row
                    HStack {
                        Text("Serial Number")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Test Name")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Fees")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    
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
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                }
                .background(Color("LightColor").opacity(0.7))
                .cornerRadius(10)
                .padding()
            }  .background(Color("LightColor").opacity(0.7))
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
