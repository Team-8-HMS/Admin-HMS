
//  DoctorView.swift
//  HMS_admin_Demo_02
//
//  Created by Sameer Verma on 06/07/24.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct DoctorView: View {
    @State private var searchText = ""
    @State private var doctors = [Doctor]()
    @State private var showAddDoctor = false
    @State private var selectedDoctor: Doctor?
    @State private var isEditing = false
    @State private var showSuccessMessage = false
    @State private var successMessage = ""
    @State private var showDoctorDetail = false
    
    var filteredDoctors: [Doctor] {
        if searchText.isEmpty {
            return doctors
        } else {
            let lowercasedSearchText = searchText.lowercased()
            return doctors.filter {
                $0.name.lowercased().contains(lowercasedSearchText) ||
                $0.department.lowercased().contains(lowercasedSearchText)
            }
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
                    .cornerRadius(20)
                }
                .padding(.horizontal)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 197), spacing: 40)]) {
                        ForEach(filteredDoctors) { doctor in
                            Button(action: {
                                selectedDoctor = doctor
                                showDoctorDetail = true
                            }) {
                                DoctorCardView(doctor: doctor)
                            }
                        }
                    }
                    .padding()
                }
                Spacer()
            }
            .padding()
            .alert(isPresented: $showSuccessMessage) {
                Alert(title: Text("Success"), message: Text(successMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear(perform: fetchDoctors)
            .background(Color("LightColor").opacity(0.7))
            .fullScreenCover(item: $selectedDoctor) { doctor in
                DoctorDetailView(
                    doctor: doctor,
                    onBack: {
                        selectedDoctor = nil
                    },
                    onRemove: {
                        if let index = doctors.firstIndex(of: doctor) {
                            removeDoctorFromFirestore(doctor: doctor)
                            doctors.remove(at: index)
                            selectedDoctor = nil
                        }
                    },
                    onEdit: {
                        selectedDoctor = doctor
                        isEditing = true
                    }
                )
                .navigationBarHidden(true)
                .sheet(isPresented: $isEditing) {
                    EditDoctorView(isPresented: $isEditing, doctor: $selectedDoctor, doctors: $doctors, showSuccessMessage: $showSuccessMessage, successMessage: $successMessage)
                        .onDisappear {
                            selectedDoctor = nil
                        }
                }
            }
            .navigationTitle("Doctors")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddDoctor.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus")
//                            Text("Add Doctor")
                        }
                    }
                    .sheet(isPresented: $showAddDoctor) {
                        AddDoctorView(isPresented: $showAddDoctor, doctors: $doctors, showSuccessMessage: $showSuccessMessage, successMessage: $successMessage)
                    }
                }
            }
        }
    }
    
    private func fetchDoctors() {
        let db = Firestore.firestore()
        db.collection("Doctors").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
            } else {
                if let snapshot = snapshot {
                    self.doctors = snapshot.documents.compactMap { doc -> Doctor? in
                        try? doc.data(as: Doctor.self)
                    }
                }
            }
        }
    }
    
    private func removeDoctorFromFirestore(doctor: Doctor) {
        let db = Firestore.firestore()
        db.collection("Doctors").document("\(doctor.id)").delete { error in
            if let error = error {
                print("Error deleting doctor: \(error.localizedDescription)")
            } else {
                print("Doctor deleted successfully")
                if let imageURL = doctor.imageURL {
                    let storageRef = Storage.storage().reference(forURL: imageURL.absoluteString)
                    storageRef.delete { error in
                        if let error = error {
                            print("Error deleting image: \(error.localizedDescription)")
                        } else {
                            print("Image deleted successfully")
                        }
                    }
                }
            }
        }
    }
}
