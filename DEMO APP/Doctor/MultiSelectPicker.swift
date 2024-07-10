//
//  MultiSelectPicker.swift
//  DEMO APP
//
//  Created by Sameer Verma on 10/07/24.
//

import Foundation
import SwiftUI

struct MultiSelectPicker: View {
    @Binding var selectedItems: [String]
    let items: [String]
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            List(items, id: \.self) { item in
                Button(action: {
                    if selectedItems.contains(item) {
                        selectedItems.removeAll { $0 == item }
                    } else {
                        selectedItems.append(item)
                    }
                }) {
                    HStack {
                        Text(item)
                        Spacer()
                        if selectedItems.contains(item) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            Button("Done") {
                isPresented = false
            }
            .padding()
        }
    }
}
