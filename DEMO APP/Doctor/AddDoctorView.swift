//
//  AddDoctorView.swift
//  DEMO APP
//
//  Created by Sameer Verma on 10/07/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct AddDoctorView: View {
    @Binding var isPresented: Bool
    @Binding var doctors: [Doctor]
    @Binding var showSuccessMessage: Bool
    @Binding var successMessage: String
    
    @State private var id: String = ""
    @State private var name: String = ""
    @State private var contactNo: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var gender: String = "Male"
    @State private var dob: Date = Date()
    @State private var showDobPicker = false
    @State private var department: String = "General"
    @State private var showDepartmentPicker = false
    @State private var image: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var degree: String = ""
    @State private var entryTime: Date = Date()
    @State private var exitTime: Date = Date()
    @State private var visitingFees: Int = 0
    @State private var status: Bool = false
    @State private var workingDays: [String] = []
    @State private var showWorkingDaysPicker = false
    @State private var yearsOfExperience: Int = 0
    @State private var idNumber: Int = 0
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    private static var generatedIDs: Set<Int> = []
    
    let genders = ["Male", "Female", "Others"]
    let departments = ["General", "Cardiology", "Neurology", "Pediatrics", "Dermatology", "Ophthalmology"]
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    init(isPresented: Binding<Bool>, doctors: Binding<[Doctor]>, showSuccessMessage: Binding<Bool>, successMessage: Binding<String>) {
        self._isPresented = isPresented
        self._doctors = doctors
        self._showSuccessMessage = showSuccessMessage
        self._successMessage = successMessage
        self._idNumber = State(initialValue: idNumber)
    }
    
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
                    Button(action: {
                        showDobPicker.toggle()
                    }) {
                        HStack {
                            Text("Select Date of Birth")
                            Spacer()
                            Text("\(DateFormatter.shortDate.string(from: dob))")
                        }
                    }
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
                        Text("Experience should be less than age minus 25")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Add Doctor", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Add") {
                    if validateFields() {
                        addDoctor()
                    }
                }
            )
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $image)
            }
            .sheet(isPresented: $showDobPicker) {
                VStack {
                    DatePicker("Select Date of Birth", selection: $dob, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                    Button("Done") {
                        showDobPicker = false
                    }
                    .padding()
                }
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
        if name.isEmpty || contactNo.isEmpty || address.isEmpty || degree.isEmpty || department.isEmpty || workingDays.isEmpty || image == nil {
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
    
    private func validateEmail() -> Bool {
        let allowedDomains = [
            "gmail.com", "yahoo.com", "hotmail.com", "outlook.com", "icloud.com",
            "aol.com", "mail.com", "zoho.com", "protonmail.com", "gmx.com","galgotiasuniversity.edu.in"
        ]
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@(" + allowedDomains.joined(separator: "|") + ")$"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
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
    
    private func addDoctor() {
        guard let image = image else {
            errorMessage = "Please select an image."
            showErrorMessage = true
            return
        }
        
        // Upload image to Firebase Storage
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("images/\(UUID().uuidString).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            imagesRef.putData(imageData, metadata: metadata) { metadata, error in
                guard metadata != nil else {
                    errorMessage = "Failed to upload image: \(error?.localizedDescription ?? "Unknown error")"
                    showErrorMessage = true
                    return
                }
                // You can also access the download URL after upload.
                imagesRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        errorMessage = "Failed to retrieve image URL: \(error?.localizedDescription ?? "Unknown error")"
                        showErrorMessage = true
                        return
                    }
                    saveDoctorData(imageURL: downloadURL)
                }
            }
        }
    }
    
    private func saveDoctorData(imageURL: URL) {
        
//        doctorItemCount()
        let db = Firestore.firestore()
        Auth.auth().createUser(withEmail: email, password: "HMS@123") { authResult, error in
            if let error = error {
                errorMessage = "Failed to create user: \(error.localizedDescription)"
                showErrorMessage = true
                return
            }
            
            guard let userID = authResult?.user.uid else {
                errorMessage = "Failed to get user ID"
                showErrorMessage = true
                return
            }
            
            let newDoctor = Doctor(id: userID, idNumber: idNumber,
                                   name: name,
                                   contactNo: contactNo,
                                   email: email,
                                   address: address,
                                   gender: gender,
                                   dob: dob,
                                   degree: degree,
                                   department: department,
                                   status: status,
                                   entryTime: entryTime,
                                   exitTime: exitTime,
                                   visitingFees: visitingFees,
                                   imageURL: imageURL,
                                   workingDays: workingDays,
                                   yearsOfExperience: yearsOfExperience)
            let doctorData = newDoctor.toDictionary()
            
            db.collection("Doctors").document(userID).setData(doctorData) { error in
                if let error = error {
                    errorMessage = "Failed to save doctor data: \(error.localizedDescription)"
                    showErrorMessage = true
                } else {
                    doctors.append(newDoctor)
                    successMessage = "Doctor added successfully"
                    showSuccessMessage = true
                    isPresented = false
                }
            }
        }
    }
}
