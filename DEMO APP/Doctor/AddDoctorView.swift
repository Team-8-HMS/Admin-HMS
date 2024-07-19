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
import SwiftSMTP

struct AddDoctorView: View {
    class EmailSender {
        static let shared = EmailSender()
        private init() {}
        
        func sendEmail(subject: String, body: String, to: String, from: String, smtpHost: String, smtpPort: Int, username: String, password: String) {
            let smtp = SMTP(hostname: smtpHost, email: from, password: password, port: Int32(smtpPort), tlsMode: .requireSTARTTLS, tlsConfiguration: nil)
            
            let fromEmail = Mail.User(name: "Sender Name", email: from)
            let toEmail = Mail.User(name: "Recipient Name", email: to)
            
            let mail = Mail(
                from: fromEmail,
                to: [toEmail],
                subject: subject,
                text: body
            )
            
            smtp.send(mail) { (error) in
                if let error = error {
                    print("Error sending email: \(error)")
                } else {
                    print("Email sent successfully!")
                }
            }
        }
    }

    @Binding var isPresented: Bool
    @Binding var doctors: [Doctor]
    @Binding var showSuccessMessage: Bool
    @Binding var successMessage: String
    
    @State private var id: String = ""
    @State private var name: String = ""
    @State private var contactNo: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var gender: String = "Select Gender"
    @State private var dob: Date = Date()
    @State private var showDobPicker = false
    @State private var department: String = "General"
    @State private var showDepartmentPicker = false
    @State private var image: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var degree: String = "Select Degree"
    @State private var showDegreePicker = false
    @State private var entryTime: Date = Date()
    @State private var showEntryTimePicker = false
    @State private var exitTime: Date = Date()
    @State private var showExitTimePicker = false
    @State private var visitingFees: String = ""
    @State private var status: Bool = false
    @State private var workingDays: [String] = []
    @State private var showWorkingDaysPicker = false
    @State private var yearsOfExperience: String = ""
    @State private var idNumber: String = ""
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    @State private var showDiscardMessage = false
    @State private var emailError: String? = nil
    @State private var contactNumberError: String? = nil
    private static var generatedIDs: Set<Int> = []
    
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
    
    init(isPresented: Binding<Bool>, doctors: Binding<[Doctor]>, showSuccessMessage: Binding<Bool>, successMessage: Binding<String>) {
        self._isPresented = isPresented
        self._doctors = doctors
        self._showSuccessMessage = showSuccessMessage
        self._successMessage = successMessage
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button("Cancel") {
                        showDiscardMessage.toggle()
                    }
                    .foregroundColor(.blue)

                    Spacer()

                    Text("Add Doctor")
                        .font(.headline)

                    Spacer()

                    Button("Add") {
                        if validateFields() {
                            addDoctor()
                        }
                    }
                    .disabled(!isSaveButtonEnabled)
                    .foregroundColor(isSaveButtonEnabled ? .blue : .gray)
                }
                .padding()

                Form {
                    // Profile Picture Section
                    Section(header: Text("Profile Photo"))  {
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

                    // Name and Medical ID Section
                    Section(header: Text("Name")) {
                        TextField("Enter Name", text: $name)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .frame(height: 40)
                            .padding(.horizontal)
                 
                        
                        TextField("Enter Medical ID Number", text: $idNumber)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .frame(height: 40)
                            .padding(.horizontal)
                        
                        
                    }

                    // Contact Information Section
                    Section(header: Text("Contact Information")) {
                        TextField("Contact No", text: $contactNo)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .frame(height: 40)
                            .padding(.horizontal)
                            .onChange(of: contactNo) { newValue in
                                validateFields()
                            }
                        if let contactNumberError = contactNumberError {
                            Text(contactNumberError).foregroundColor(.black)
                        }
                       
                        
                        TextField("Enter Email", text: $email)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .frame(height: 40)
                            .padding(.horizontal)
                           
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
                        
                        TextField("Address", text: $address)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .frame(height: 40)
                            .padding(.horizontal)
                           
                    }

                    // Personal Information Section
                    Section(header: Text("Personal Information")) {
                        Button(action: {
                            showDobPicker.toggle()
                        }) {
                            HStack {
                                Text("Select Date of Birth")
                                Spacer()
                                Text("\(DateFormatter.shortDate.string(from: dob))")
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .frame(height: 40)
                        .padding(.horizontal)
                     
                        // Gender selection as a popup menu
                        Menu {
                            ForEach(genders, id: \.self) { genderOption in
                                Button(action: {
                                    self.gender = genderOption
                                }) {
                                    Text(genderOption)
                                }
                            }
                        } label: {
                            HStack {
                                Text("Gender")
                                    .foregroundColor(.black)
                                Spacer()
                                Text(gender)
                                    .foregroundColor(.blue)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .frame(height: 40)
                            .padding(.horizontal)
                        }
                        
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
                                Text("Degree")
                                    .foregroundColor(.black)
                                Spacer()
                                Text(degree)
                                    .foregroundColor(.blue)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .frame(height: 40)
                            .padding(.horizontal)
                          
                        }
                    }
                    
                    // Working Information Section
                    Section(header: Text("Working Information")) {
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
                                Text("Department")
                                    .foregroundColor(.black)
                                Spacer()
                                Text(department)
                                    .foregroundColor(.blue)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .frame(height: 40)
                            .padding(.horizontal)
                         
                        }
                        
                        Button(action: {
                            showWorkingDaysPicker.toggle()
                        }) {
                            HStack {
                                Text("Select Working Days")
                                Spacer()
                                Text(workingDays.isEmpty ? "None" : workingDays.joined(separator: ", "))
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .frame(height: 40)
                        .padding(.horizontal)
                        
                        Toggle("Active", isOn: $status)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .frame(height: 40)
                            .padding(.horizontal)
                          
                        
                        TextField("Enter Fees", text: $visitingFees)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .frame(height: 40)
                            .padding(.horizontal)
                          
                            .onChange(of: visitingFees) { newValue in
                                validateFees()
                            }
                            
                        if let fee = Int(visitingFees), fee <= 0 || fee > 10000 {
                            Text("Fees should be between 1 and 10,000")
                                .foregroundColor(.black)
                                .padding(.horizontal)
                        }
                        
                        TextField("Enter Years of Experience", text: $yearsOfExperience)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .frame(height: 40)
                            .padding(.horizontal)
                           
                            .onChange(of: yearsOfExperience) { newValue in
                                validateExperience()
                            }
                            
                        if let experience = Int(yearsOfExperience), experience >= doctorAge() - 25 || experience < 0 {
                            Text("Experience should be less than age minus 25")
                                .foregroundColor(.black)
                                .padding(.horizontal)
                        }
                        
                        Button(action: {
                            showEntryTimePicker.toggle()
                        }) {
                            HStack {
                                Text("Select Entry Time")
                                    .foregroundColor(.black)
                                Spacer()
                                Text("\(DateFormatter.shortTime.string(from: entryTime))")
                                    .foregroundColor(.blue)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .frame(height: 40)
                            .padding(.horizontal)
                        }
                        .sheet(isPresented: $showEntryTimePicker) {
                            VStack {
                                DatePicker("Select Entry Time", selection: $entryTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                    .padding()
                                Button("Done") {
                                    showEntryTimePicker = false
                                }
                                .padding()
                            }
                        }
                        
                        Button(action: {
                            showExitTimePicker.toggle()
                        }) {
                            HStack {
                                Text("Select Exit Time")
                                    .foregroundColor(.black)
                                Spacer()
                                Text("\(DateFormatter.shortTime.string(from: exitTime))")
                                    .foregroundColor(.blue)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .frame(height: 40)
                            .padding(.horizontal)
                        }
                        .sheet(isPresented: $showExitTimePicker) {
                            VStack {
                                DatePicker("Select Exit Time", selection: $exitTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                    .padding()
                                Button("Done") {
                                    showExitTimePicker = false
                                }
                                .padding()
                            }
                        }
                    }
                }
                .alert(isPresented: $showErrorMessage) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showDiscardMessage) {
                Alert(
                    title: Text("Are you sure you want to discard this new Doctor?"),
                    primaryButton: .destructive(Text("Discard Changes")) {
                        isPresented = false
                    },
                    secondaryButton: .cancel()
                )
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
        }
    }
    
    private var isSaveButtonEnabled: Bool {
        return !name.isEmpty && !contactNo.isEmpty && !email.isEmpty && !address.isEmpty && !degree.isEmpty && !department.isEmpty && !workingDays.isEmpty && image != nil
    }

    private func validateFields() -> Bool {
        
        if name.isEmpty || contactNo.isEmpty || address.isEmpty || degree.isEmpty || department.isEmpty || workingDays.isEmpty || image == nil {
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
        
        return true
    }
    
    private func validateFees() {
        if let fee = Int(visitingFees), fee <= 0 || fee > 10000 {
            errorMessage = "Fees should be between 1 and 10,000"
            showErrorMessage = true
        } else {
            errorMessage = ""
            showErrorMessage = false
        }
    }

//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Z]{2,}$"
//        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
//        return emailPred.evaluate(with: email)
//    }

    private func validateExperience() {
        if let experience = Int(yearsOfExperience), experience >= doctorAge() - 25 {
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
                    saveDoctorData(imageURL: downloadURL)
                }
            }
        }
    }
    
    private func saveDoctorData(imageURL: URL) {
        let db = Firestore.firestore()
        do {
            EmailSender.shared.sendEmail(
                subject: "Credentials for \(name)",
                body: """
                Dear \(name),
                
                I hope this message finds you well.

                Please find below the login credentials for \(name). These credentials will allow you to access the necessary systems and resources:
                Email: \(email)
                Temporary Password: HMS@123
                """,
                to: "\(email)",
                from: "gumaclab@gmail.com",
                smtpHost: "smtp.gmail.com",
                smtpPort: 587,
                username: "gumaclab@gmail.com",
                password: "cfmn rzgw ovyh krud"
            )

            Auth.auth().createUser(withEmail: email, password: "HMS@123") { authResult, error in
                if let error = error {
                    print("error")
                } else {
                    if let authResult = authResult {
                        let userID = authResult.user.uid
                       
                        let newDoctor = Doctor(id: userID, idNumber: Int(idNumber) ?? 0,
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
                                               visitingFees: Int(visitingFees) ?? 0,
                                               imageURL: imageURL,
                                               workingDays: workingDays,
                                               yearsOfExperience: Int(yearsOfExperience) ?? 0)
                        let doctorData = newDoctor.toDictionary()
                        do {
                            try db.collection("Doctors").document(userID).setData(doctorData)
                            
                            doctors.append(newDoctor)
                            successMessage = "Doctor Added Successfully"
                            showSuccessMessage = true
                            isPresented = false
                        } catch {
                            print("Error setting Doctor data: \(error.localizedDescription)")
                        }
                    }
                }
            }
        } catch let error {
            print("Error writing doctor to Firestore: \(error)")
        }
    }
}
