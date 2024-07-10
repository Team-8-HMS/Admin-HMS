//
//  EditDoctorView.swift
//  DEMO APP
//
//  Created by Sameer Verma on 10/07/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct EditDoctorView: View {
    @Binding var isPresented: Bool
    @Binding var doctor: Doctor?
    @Binding var doctors: [Doctor]
    @Binding var showSuccessMessage: Bool
    @Binding var successMessage: String
    
    @State private var idNumber: Int = 0
    @State private var name: String = ""
    @State private var contactNo: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var gender: String = "Male"
    @State private var dob: Date = Date()
    @State private var degree: String = ""
    @State private var department: String = ""
    @State private var showDepartmentPicker = false
    @State private var image: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var entryTime: Date = Date()
    @State private var exitTime: Date = Date()
    @State private var visitingFees: Int = 0
    @State private var status: Bool = false
    @State private var workingDays: [String] = []
    @State private var showWorkingDaysPicker = false
    @State private var yearsOfExperience: Int = 0
    @State private var imageURL: URL?
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    
    let genders = ["Male", "Female", "Others"]
    let departments = ["General", "Cardiology", "Neurology", "Pediatrics", "Dermatology", "Ophthalmology"]
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Photo")) {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                    } else {
                        Text("Tap to select a photo")
                            .foregroundColor(.blue)
                    }
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                Section(header: Text("ID Number")) {
                    TextField("Enter ID Number", value: $idNumber, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Name")) {
                    TextField("Enter Name", text: $name)
                }
                Section(header: Text("Contact No")) {
                    TextField("Contact No", text: $contactNo)
                        .keyboardType(.numberPad)
                }
                
                
//-----------------------------
                
                Section(header: Text("E-mail")) {
                    TextField("Enter Email (Optional)", text: $email)
                        .onChange(of: email) { newValue in
                            isValidEmail(email)
                        }
                        .overlay(HStack {
                        Spacer()
                        if email.isEmpty {
                            Image(systemName: "")
                                .padding()
                        } else if isValidEmail(email) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .padding()
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .padding()
                        }
                    })
                    
                }
                
//--------------------------------------------
                Section(header: Text("Address")) {
                    TextField("Address", text: $address)
                }
                Section(header: Text("Gender")) {
                    Picker("Select Gender", selection: $gender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                Section(header: Text("DOB")) {
                    DatePicker("Select Date of Birth", selection: $dob, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                Section(header: Text("Degree")) {
                    TextField("Enter Degree", text: $degree)
                }
                Section(header: Text("Department")) {
                    Button(action: {
                        showDepartmentPicker.toggle()
                    }) {
                        HStack {
                            Text("Select Department")
                            Spacer()
                            Text(department.isEmpty ? "None" : department)
                        }
                    }
                }
                Section(header: Text("Working Days")) {
                    Button(action: {
                        showWorkingDaysPicker.toggle()
                    }) {
                        HStack {
                            Text("Select Working Days")
                            Spacer()
                            Text(workingDays.isEmpty ? "None" : workingDays.joined(separator: ", "))
                        }
                    }
                }
                Section(header: Text("Status")) {
                    Toggle("Active", isOn: $status)
                }
                Section(header: Text("Entry Time")) {
                    DatePicker("Select Entry Time", selection: $entryTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .onChange(of: entryTime) { newValue in
                            exitTime = Calendar.current.date(byAdding: .hour, value: 4, to: newValue) ?? Date()
                        }
                }
                Section(header: Text("Exit Time")) {
                    DatePicker("Select Exit Time", selection: $exitTime, in: entryTime.addingTimeInterval(14400)..., displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                }
                Section(header: Text("Fees")) {
                    TextField("Enter Fees", value: $visitingFees, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .onChange(of: visitingFees) { newValue in
                            validateFees()
                        }
                    if visitingFees <= 0 || visitingFees > 10000 {
                        Text("Fees should be between 1 and 10,000")
                            .foregroundColor(.red)
                    }
                }
                
                
                Section(header: Text("Years of Experience")) {
                    TextField("Enter Years of Experience", value: $yearsOfExperience, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .onChange(of: yearsOfExperience) { newValue in
                            validateExperience()
                        }
                    if yearsOfExperience >= doctorAge() - 25 {
                        Text("Experience should be less than (age - 25)")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Edit Doctor", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    if validateFields() {
                        if let doctor = doctor {
                            if let image = image {
                                uploadImageAndUpdateDoctor(doctor: doctor)
                            } else {
                                updateDoctorData(doctor: doctor, imageURL: doctor.imageURL)
                            }
                            showSuccessMessage = true
                            successMessage = "Doctor Edited Successfully"
                        }
                    }
                }
            )
            .onAppear {
                if let doctor = doctor {
                    idNumber = doctor.idNumber
                    name = doctor.name
                    contactNo = doctor.contactNo
                    email = doctor.email
                    address = doctor.address
                    gender = doctor.gender
                    dob = doctor.dob
                    department = doctor.department
                    degree = doctor.degree
                    entryTime = doctor.entryTime
                    exitTime = doctor.exitTime
                    visitingFees = doctor.visitingFees
                    status = doctor.status
                    workingDays = doctor.workingDays
                    yearsOfExperience = doctor.yearsOfExperience
                    imageURL = doctor.imageURL
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $image)
            }
            .sheet(isPresented: $showDepartmentPicker) {
                VStack {
                    List(departments, id: \.self) { dept in
                        Button(action: {
                            department = dept
                            showDepartmentPicker = false
                        }) {
                            Text(dept)
                                .foregroundColor(department == dept ? .blue : .primary)
                        }
                    }
                    Button("Done") {
                        showDepartmentPicker = false
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showWorkingDaysPicker) {
                MultiSelectPicker(selectedItems: $workingDays, items: daysOfWeek, isPresented: $showWorkingDaysPicker)
            }
            .alert(isPresented: $showErrorMessage) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func validateFields() -> Bool {
        if name.isEmpty || contactNo.isEmpty || address.isEmpty || degree.isEmpty || department.isEmpty || workingDays.isEmpty {
            errorMessage = "All fields are mandatory."
            showErrorMessage = true
            return false
        }
        
        if contactNo.count != 10 {
            errorMessage = "Contact number should be exactly 10 digits."
            showErrorMessage = true
            return false
        }
        
        return true
    }
    
    private func validateFees() {
        if visitingFees <= 0 || visitingFees > 10000 {
            errorMessage = "Fees should be between 1 and 10,000"
            showErrorMessage = true
        } else {
            errorMessage = ""
            showErrorMessage = false
        }
    }
    
    private func validateExperience() {
        if yearsOfExperience >= doctorAge() - 25 {
            errorMessage = "Experience should be less than age minus 25"
            showErrorMessage = true
        } else {
            errorMessage = ""
            showErrorMessage = false
        }
    }
    
    private func doctorAge() -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date())
        return ageComponents.year ?? 0
    }
    
    private func uploadImageAndUpdateDoctor(doctor: Doctor) {
        guard let image = image else { return }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("images/\(UUID().uuidString).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            imagesRef.putData(imageData, metadata: metadata) { metadata, error in
                guard metadata != nil else {
                    // Uh-oh, an error occurred!
                    return
                }
                imagesRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    updateDoctorData(doctor: doctor, imageURL: downloadURL)
                }
            }
        }
    }
    
    private func validateEmail() -> Bool{
        let allowedDomains = [
            "gmail.com", "yahoo.com", "hotmail.com", "outlook.com", "icloud.com",
            "aol.com", "mail.com", "zoho.com", "protonmail.com", "gmx.com","galgotiasuniversity.edu.in"
        ]
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@(" + allowedDomains.joined(separator: "|") + ")$"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    private func updateDoctorData(doctor: Doctor, imageURL: URL?) {
        let db = Firestore.firestore()
        let doctorRef = db.collection("Doctors").document("\(doctor.id)")
        
        doctorRef.updateData([
            "idNumber": idNumber,
            "name": name,
            "contactNo": contactNo,
            "email": email,
            "address": address,
            "gender": gender,
            "dob": dob,
            "degree": degree,
            "department": department,
            "status": status,
            "entryTime": entryTime,
            "exitTime": exitTime,
            "visitingFees": visitingFees,
            "imageURL": imageURL?.absoluteString ?? doctor.imageURL?.absoluteString ?? "",
            "workingDays": workingDays,
            "yearsOfExperience": yearsOfExperience
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                
                if let index = doctors.firstIndex(where: { $0.id == doctor.id }) {
                    doctors[index].idNumber = idNumber
                    doctors[index].name = name
                    doctors[index].contactNo = contactNo
                    doctors[index].email = email
                    doctors[index].address = address
                    doctors[index].gender = gender
                    doctors[index].dob = dob
                    doctors[index].degree = degree
                    doctors[index].department = department
                    doctors[index].status = status
                    doctors[index].entryTime = entryTime
                    doctors[index].exitTime = exitTime
                    doctors[index].visitingFees = visitingFees
                    doctors[index].imageURL = imageURL
                    doctors[index].workingDays = workingDays
                    doctors[index].yearsOfExperience = yearsOfExperience
                }
                
                successMessage = "Doctor Updated Successfully"
                showSuccessMessage = true
                isPresented = false
            }
        }
    }
}
