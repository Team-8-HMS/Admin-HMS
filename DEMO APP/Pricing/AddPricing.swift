//
//  AddPricing.swift
//  DEMO APP
//
//  Created by Sameer Verma on 08/07/24.
//

import SwiftUI
import FirebaseFirestore

struct AddTestView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var price: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    var onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Test Name", text: $name)
                TextField("Test Fee", text: $price)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add New Test")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let fee = Double(price) else {
                            alertMessage = "Please enter a valid number for the Test Fee."
                            showAlert = true
                            return
                        }
                        let newTest = MedicalTest(name: name, price: fee)
                        let db = Firestore.firestore()
                        
                        do {
                            let testData = newTest.toDictionary()
                            try db.collection("LabTestPrices").document("\(newTest.id)").setData(testData)
                            presentationMode.wrappedValue.dismiss()
                            onSave()
                        } catch let error {
                            alertMessage = "Error writing document to Firestore: \(error)"
                            showAlert = true
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Input"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

