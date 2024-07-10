//
//  DoctorDetailView.swift
//  DEMO APP
//
//  Created by Sameer Verma on 10/07/24.
//

import Foundation
import SwiftUI

struct DoctorDetailView: View {
    var doctor: Doctor
    var onBack: () -> Void
    var onRemove: () -> Void
    var onEdit: () -> Void
    
    @State private var image: UIImage?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Button(action: {
                        onBack()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    Spacer()
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                    Spacer()
                }
                .padding(.bottom)
                
                Text(doctor.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Age: \(doctor.age)")
                    .font(.headline)
                
                Form {
                    Section(header: Text("ID Number")) {
                        Text("\(doctor.idNumber)")
                    }
                    Section(header: Text("Address")) {
                        Text(doctor.address)
                    }
                    Section(header: Text("Email")) {
                        Text(doctor.email)
                    }
                    Section(header: Text("Phone")) {
                        Text(doctor.contactNo)
                    }
                    Section(header: Text("Gender")) {
                        Text(doctor.gender)
                    }
                    Section(header: Text("DOB")) {
                        Text(DateFormatter.shortDate.string(from: doctor.dob))
                    }
                    Section(header: Text("Degree")) {
                        Text(doctor.degree)
                    }
                    Section(header: Text("Department")) {
                        Text(doctor.department)
                    }
                    Section(header: Text("Years of Experience")) {
                        Text("\(doctor.yearsOfExperience) years")
                    }
                    Section(header: Text("Working Days")) {
                        Text(doctor.workingDays.joined(separator: ", "))
                    }
                    Section(header: Text("Status")) {
                        Text(doctor.status ? "Active" : "Inactive")
                    }
                    
                    Section(header: Text("Fees")) {
                        Text("\(doctor.visitingFees)")
                    }
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        onEdit()
                    }) {
                        Text("Edit")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        onRemove()
                    }) {
                        Text("Remove")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .onAppear {
                if let url = doctor.imageURL {
                    loadImage(from: url)
                }
            }
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to load image from \(url): \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }.resume()
    }
}
