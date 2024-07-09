//
//  EditPricing.swift
//  DEMO APP
//
//  Created by Sameer Verma on 08/07/24.
//

import SwiftUI
import FirebaseFirestore

struct EditTestView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var test: MedicalTest
    @State private var name: String
    @State private var price: Double
    var onSave: () -> Void

    init(test: MedicalTest, onSave: @escaping () -> Void) {
        self._test = State(initialValue: test)
        self._name = State(initialValue: test.name)
        self._price = State(initialValue: test.price)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    TextField("Test Name", text: $name)
                    TextField("Price", value: $price, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }
                
                Spacer()
                
                Button("Remove Test", role: .destructive) {
                    removeTest()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }
            .navigationTitle("Edit Test")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
    }

    private func saveChanges() {
        let db = Firestore.firestore()
        let testRef = db.collection("LabTestPrices").document(test.id.uuidString)
        testRef.updateData(["name": name, "price": price]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                presentationMode.wrappedValue.dismiss()
                onSave()
            }
        }
    }

    private func removeTest() {
        let db = Firestore.firestore()
        db.collection("LabTestPrices").document(test.id.uuidString).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed")
                presentationMode.wrappedValue.dismiss()
                onSave()
            }
        }
    }
}
