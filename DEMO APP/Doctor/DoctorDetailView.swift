//
//  DoctorDetailView.swift
//  DEMO APP
//
//  Created by Sameer Verma on 10/07/24.
//
import SwiftUI
import Foundation

struct DoctorDetailView: View {
    var doctor: Doctor
    var onBack: () -> Void
    var onRemove: () -> Void
    var onEdit: () -> Void
    
    @State private var image: UIImage?
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let imageURL = doctor.imageURL, let url = URL(string: imageURL.absoluteString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .padding(.top, 20)
                        case .failure:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .padding(.top, 20)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .padding(.top, 20)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                }
                
                Text(doctor.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Form {
                    Section(header: Text("ID Number")) {
                        HStack {
                            Text("ID Number")
                            Spacer()
                            Text("\(doctor.idNumber)")
                        }
                    }
                    Section(header: Text("Contact Details")) {
                        HStack {
                            Text("Phone")
                            Spacer()
                            Text(doctor.contactNo)
                        }
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(doctor.email)
                        }
                    }
                    Section(header: Text("Other Details")) {
                        HStack {
                            Text("Date of Birth")
                            Spacer()
                            Text(DateFormatter.shortDate.string(from: doctor.dob))
                        }
                        HStack {
                            Text("Gender")
                            Spacer()
                            Text(doctor.gender)
                        }
                        HStack {
                            Text("Address")
                            Spacer()
                            Text(doctor.address)
                        }
                        HStack {
                            Text("Degree")
                            Spacer()
                            Text(doctor.degree)
                        }
                        HStack {
                            Text("Department")
                            Spacer()
                            Text(doctor.department)
                        }
                        HStack {
                            Text("Years of Experience")
                            Spacer()
                            Text("\(doctor.yearsOfExperience) years")
                        }
                        HStack {
                            Text("Working Days")
                            Spacer()
                            Text(doctor.workingDays.joined(separator: ", "))
                        }
                        HStack {
                            Text("Entry Time")
                            Spacer()
                            Text(DateFormatter.timeFormatter.string(from: doctor.entryTime))
                        }
                        HStack {
                            Text("Exit Time")
                            Spacer()
                            Text(DateFormatter.timeFormatter.string(from: doctor.exitTime))
                        }
                        HStack {
                            Text("Status")
                            Spacer()
                            Text(doctor.status ? "Active" : "Inactive")
                        }
                    }
                    Section(header: Text("Fees")) {
                        HStack {
                            Text("Visiting Fees")
                            Spacer()
                            Text("\(doctor.visitingFees)")
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                Spacer()
            }
            .navigationBarTitle("Doctor Details", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                onBack()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        onEdit()
                    }) {
                        Text("Edit")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        showAlert = true
                    }) {
                        Text("Remove")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .cornerRadius(20)
                    }
                }
            }
            .onAppear {
                if let url = doctor.imageURL {
                    loadImage(from: url)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Confirm Removal"),
                    message: Text("Are you sure you want to remove this doctor?"),
                    primaryButton: .destructive(Text("Yes")) {
                        onRemove()
                    },
                    secondaryButton: .cancel()
                )
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
