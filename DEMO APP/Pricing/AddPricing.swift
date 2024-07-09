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
    @State private var price: Double = 0.0
    var onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Test Name", text: $name)
                TextField("Price", value: $price, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add New Test")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newTest = MedicalTest(name: name, price: price)
                        let db = Firestore.firestore()
                        
                        do {
                            let testData = newTest.toDictionary()
                            try db.collection("LabTestPrices").document("\(newTest.id)").setData(testData)
                            presentationMode.wrappedValue.dismiss()
                            onSave()
                        } catch let error {
                            print("Error writing document to Firestore: \(error)")
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

