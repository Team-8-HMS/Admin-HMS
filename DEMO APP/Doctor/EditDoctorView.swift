//
//  EditDoctorView.swift
//  DEMO APP
//
//  Created by Sameer Verma on 10/07/24.
//

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
    @State private var gender: String = "Select Gender"
    @State private var dob: Date = Date()
    @State private var degree: String = "Select Degree"
    @State private var department: String = "Select Department"
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
    @State private var emailError: String? = nil
    @State private var contactNumberError: String? = nil

    
    let genders = ["Select Gender", "Male", "Female", "Others"]
    let departments = ["General", "Cardiology", "Neurology", "Pediatrics", "Dermatology", "Ophthalmology"]
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let degrees = [
        "Doctor of Medicine (MD)",
        "Doctor of Osteopathic Medicine (DO)",
        "Bachelor of Medicine, Bachelor of Surgery (MBBS or MBChB)",
        "Doctor of Dental Surgery (DDS) or Doctor of Dental Medicine (DMD)",
        "Doctor of Podiatric Medicine (DPM)",
        "Doctor of Veterinary Medicine (DVM)",
        "Doctor of Optometry (OD)",
        "Doctor of Chiropractic (DC)",
        "Doctor of Pharmacy (PharmD)",
        "Doctor of Psychology (PsyD)"
    ]
    
    var isSaveButtonEnabled: Bool {
        return !name.isEmpty && !contactNo.isEmpty && !address.isEmpty && !degree.isEmpty && !department.isEmpty && !workingDays.isEmpty && contactNo.count == 10 && visitingFees > 0 && visitingFees <= 10000 && yearsOfExperience < doctorAge() - 25
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button("Back") {
                        isPresented = false
                    }
                    .foregroundColor(.blue)

                    Spacer()

                    Text("Edit Doctor")
                        .font(.headline)

                    Spacer()

                    Button("Save") {
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
                    .disabled(!isSaveButtonEnabled)
                    .foregroundColor(isSaveButtonEnabled ? .blue : .gray)
                }
                .padding()

                Form {
                    // Profile Picture Section
                    Section(header: Text("Profile Photo")) {
                        HStack {
                            Spacer()
                            Button(action: {
                                showingImagePicker.toggle()
                            }) {
                                if let image = image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                        .shadow(radius: 2)
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                        .shadow(radius: 2)
                                }
                            }
                            .sheet(isPresented: $showingImagePicker) {
                                ImagePicker(image: $image)
                            }
                            Spacer()
                        }
                    }

                    // ID Section
                    Section(header: Text("Medical ID Number")) {
                        HStack {
                            Text("Medical ID Number")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            TextField("Enter Medical ID Number", value: $idNumber, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }

                    // Name Section
                    Section(header: Text("Name")) {
                        HStack {
                            Text("Name")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            TextField("Enter Name", text: $name)
                                .multilineTextAlignment(.trailing)
                        }
                    }

                    // Contact Information Section
                    Section(header: Text("Contact Details")) {
                        HStack {
                            Text("Contact No")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            TextField("Contact No", text: $contactNo)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: contactNo) { _ in
                                    validateFields()
                                }
                        }
                        if let contactNumberError = contactNumberError {
                            Text(contactNumberError).foregroundColor(.red)
                        }
                        HStack {
                            Text("E-mail")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
            
                            TextField("Email ID", text: $email)
                                .keyboardType(.emailAddress)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: email) { _ in
                                    validateFields()
                                }
                        }
                        if let emailError = emailError  {

                                Text(emailError)
                                    .foregroundColor(.red)
                            }
                        HStack {
                            Text("Address")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            TextField("Address", text: $address)
                                .multilineTextAlignment(.trailing)
                        }
                    }

                    // Other Details Section
                    Section(header: Text("Other Details")) {
                        HStack {
                            Text("Date of Birth")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            DatePicker("", selection: $dob, displayedComponents: .date)
                                .labelsHidden()
                        }
                        .frame(height: 30)
                        
                        // Gender Picker
                        HStack {
                            Text("Gender")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Menu {
                                ForEach(genders, id: \.self) { gender in
                                    Button(action: {
                                        self.gender = gender
                                    }) {
                                        Text(gender)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(gender)
                                        .foregroundColor(.blue)
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .frame(height: 30)
                                .cornerRadius(8)
                            }
                        }

                        HStack {
                            Text("Degree")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Menu {
                                ForEach(degrees, id: \.self) { degree in
                                    Button(action: {
                                        self.degree = degree
                                    }) {
                                        Text(degree)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(degree)
                                        .foregroundColor(.blue)
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .frame(height: 30)
                                .cornerRadius(8)
                            }
                        }
                        HStack {
                            Text("Department")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Menu {
                                ForEach(departments, id: \.self) { department in
                                    Button(action: {
                                        self.department = department
                                    }) {
                                        Text(department)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(department)
                                        .foregroundColor(.blue)
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .frame(height: 30)
                                .cornerRadius(8)
                            }
                        }
                        HStack {
                            Text("Working Days")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Button(action: {
                                showWorkingDaysPicker.toggle()
                            }) {
                                HStack {
                                    Text(workingDays.isEmpty ? "Select Working Days" : workingDays.joined(separator: ", "))
                                        .foregroundColor(.blue)
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .frame(height: 30)
                                .cornerRadius(8)
                            }
                        }
                        HStack {
                            Text("Entry Time")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            DatePicker("", selection: $entryTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .onChange(of: entryTime) { newValue in
                                    exitTime = Calendar.current.date(byAdding: .hour, value: 4, to: newValue) ?? Date()
                                }
                        }
                        .frame(height: 30)
                        HStack {
                            Text("Exit Time")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            DatePicker("", selection: $exitTime, in: entryTime.addingTimeInterval(14400)..., displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        .frame(height: 30)
                        HStack {
                            Text("Fees")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            TextField("Enter Fees", value: $visitingFees, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: visitingFees) { newValue in
                                    validateFees()
                                }
                        }
                        if visitingFees <= 0 || visitingFees > 10000 {
                            Text("Fees should be between 1 and 10,000")
                                .foregroundColor(.red)
                        }
                        HStack {
                            Text("Years of Experience")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            TextField("Enter Years of Experience", value: $yearsOfExperience, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: yearsOfExperience) { newValue in
                                    validateExperience()
                                }
                        }
                        if yearsOfExperience >= doctorAge() - 25 || yearsOfExperience < 0{
                            Text("Experience should be less than (age - 25)")
                                .foregroundColor(.red)
                        }

                        // Status Toggle
                        Toggle(isOn: $status) {
                            Text("Status")
                        }
                    }
                }
                .alert(isPresented: $showErrorMessage) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let doctor = doctor {
                    idNumber = doctor.idNumber
                    name = doctor.name
                    contactNo = doctor.contactNo
                    email = doctor.email
                    address = doctor.address
                    gender = doctor.gender
                    dob = doctor.dob
                    degree = doctor.degree
                    department = doctor.department
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
        }
        .navigationBarHidden(true)
    }
    
    private func validateFields() -> Bool {
        
        
        if name.isEmpty || contactNo.isEmpty || address.isEmpty || degree.isEmpty || department.isEmpty || workingDays.isEmpty {
            errorMessage = "All fields are mandatory."
            showErrorMessage = true
            return false
        }
        
        if contactNo.count != 10 {
            contactNumberError = "Contact number should be exactly 10 digits."
//            showErrorMessage = true
            return false
        }
        else{
            contactNumberError = nil
        }
        if email.contains("@@") || email.contains("..") {
            emailError = "Please Enter a Valid Email ID"
           return false
        } else if isValidEmail(email) == false {
            emailError = "Please Enter a Valid Email ID"
            return false
        }
        else {
            emailError = nil
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
                    return
                }
                imagesRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        return
                    }
                    updateDoctorData(doctor: doctor, imageURL: downloadURL)
                }
            }
        }
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
    
    private func isValidEmail(_ email: String) -> Bool {
        let allowedDomains = [
            "gmail.com", "yahoo.com", "hotmail.com", "outlook.com", "icloud.com",
            "aol.com", "mail.com", "zoho.com", "protonmail.com", "gmx.com","galgotiasuniversity.edu.in"
        ]
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@(" + allowedDomains.joined(separator: "|") + ")$"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
