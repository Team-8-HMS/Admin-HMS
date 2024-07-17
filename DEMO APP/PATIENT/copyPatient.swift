////
////  copyPatient.swift
////  DEMO APP
////
////  Created by Sameer Verma on 17/07/24.
////
//
//import SwiftUI
//import PhotosUI
//import FirebaseAuth
//import FirebaseFirestore
//import FirebaseStorage
//import SwiftSMTP
//
//
////-------------------------------------------------------
//// * MARK: -  Patient Data Model   *
//// MARK: -  Patient Data Model
//
//struct Patient: Identifiable, Codable, Equatable {
//    var id: String
//    var firstname: String
//    var lastname: String
//    var contactNumber: String
//    var email: String
//    var address: String
//    var gender: String
//    var dob: Date
//    var imageURL: URL?
//    var emergencyContact: String
//    
//    init(id: String, firstname: String, lastname: String, contactNumber: String, email: String, address: String, gender: String, dob: Date, imageURL: URL? = nil, emergencyContact: String) {
//        self.id = id
//        self.firstname = firstname
//        self.lastname = lastname
//        self.contactNumber = contactNumber
//        self.email = email
//        self.address = address
//        self.gender = gender
//        self.dob = dob
//        self.imageURL = imageURL
//        self.emergencyContact = emergencyContact
//    }
//    
//    func toDictionary() -> [String: Any] {
//        var dict: [String: Any] = [
//            "id": id,
//            "firstname": firstname,
//            "lastname": lastname,
//            "contactNumber": contactNumber,
//            "email": email,
//            "address": address,
//            "gender": gender,
//            "dob": dob,
//            "emergencyContact": emergencyContact
//        ]
//        if let imageURL = imageURL {
//            dict["imageURL"] = imageURL.absoluteString
//        }
//        return dict
//    }
//}
//
////-------------------------------------------------------
//// * MARK: -  Patient View  *
//// MARK: -  Patient View
//
//struct PatientView: View {
//    @State private var searchText = ""
//    @State private var patients = [Patient]()
//    @State private var filterText = ""
//    @State private var filterByContact = false
//    @State private var showAddPatient = false
//    @State private var showSuccessMessage = false
//    @State private var successMessage = ""
//    @State private var selectedPatient: Patient?
//    @State private var showPatientDetail = false
//    @State private var isEditing = false
//
//    var filteredPatients: [Patient] {
//        if searchText.isEmpty && filterText.isEmpty {
//            return patients
//        } else if filterByContact {
//            return patients.filter { $0.contactNumber.contains(filterText) }
//        } else {
//            return patients.filter { $0.firstname.contains(searchText) }
//        }
//    }
//
//    var body: some View {
//        VStack {
//            HStack {
//                Text("Patients")
//                    .font(.system(size: 34, weight: .bold, design: .default))
//                Spacer()
//            }
//            .padding(.top)
//
//            HStack {
//                HStack {
//                    Image(systemName: "magnifyingglass")
//                    TextField("Search", text: $searchText)
//                        .textFieldStyle(PlainTextFieldStyle())
//                    if !searchText.isEmpty {
//                        Button(action: {
//                            searchText = ""
//                        }) {
//                            Image(systemName: "xmark.circle.fill")
//                                .foregroundColor(Color(UIColor.opaqueSeparator))
//                        }
//                    }
//                }
//                .padding()
//                .background(Color(.systemGray4).opacity(0.5))
//                .cornerRadius(8)
//
//                Button(action: {
//                    filterByContact.toggle()
//                }) {
//                    Image(systemName: filterByContact ? "phone.fill" : "line.horizontal.3.decrease.circle")
//                        .padding()
//                }
//                .popover(isPresented: $filterByContact) {
//                    VStack {
//                        TextField("Filter by Contact", text: $filterText)
//                            .padding()
//                            .background(Color(.systemGray4).opacity(0.5))
//                            .cornerRadius(8)
//                        Button("Apply") {
//                            filterByContact = false
//                        }
//                        .padding()
//                    }
//                    .padding()
//                }
//
//                Spacer()
//
//                Button(action: {
//                    showAddPatient.toggle()
//                }) {
//                    HStack {
//                        Image(systemName: "plus")
//                        Text("Add Patient")
//                    }
//                    .padding()
//                    .background(Color(UIColor.systemBlue))
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                }
//                .sheet(isPresented: $showAddPatient) {
//                    AddPatientView(isPresented: $showAddPatient, patients: $patients, showSuccessMessage: $showSuccessMessage, successMessage: $successMessage)
//                }
//            }
//            .padding(.horizontal)
//
//            ScrollView {
//                LazyVGrid(columns: [GridItem(.adaptive(minimum: 197), spacing: 40)]) {
//                    ForEach(filteredPatients) { patient in
//                        Button(action: {
//                            selectedPatient = patient
//                            showPatientDetail = true
//                        }) {
//                            PatientCardView(patient: patient)
//                        }
//                    }
//                }
//                .padding()
//            }
//            Spacer()
//        }
//        .padding()
//        .alert(isPresented: $showSuccessMessage) {
//            Alert(title: Text("Success"), message: Text(successMessage), dismissButton: .default(Text("OK")))
//        }
//        .onAppear(perform: fetchPatients)
//        .background(Color(UIColor.systemBackground).opacity(0.7))
//        .fullScreenCover(item: $selectedPatient) { patient in
//            PatientDetailView(
//                patient: patient,
//                onBack: {
//                    selectedPatient = nil
//                },
//                onEdit: {
//                    selectedPatient = patient
//                    isEditing = true
//                },
//                isPresented: $selectedPatient,
//                patients: $patients,
//                showSuccessMessage: $showSuccessMessage,
//                successMessage: $successMessage
//            )
//            .navigationBarHidden(true)
//            .sheet(isPresented: $isEditing) {
//                EditPatientView(
//                    isPresented: $isEditing,
//                    patient: $selectedPatient,
//                    patients: $patients,
//                    showSuccessMessage: $showSuccessMessage,
//                    successMessage: $successMessage,
//                    parentPresentation: $selectedPatient
//                )
//                .onDisappear {
//                    selectedPatient = nil
//                }
//            }
//        }
//    }
//
//    private func fetchPatients() {
//        let db = Firestore.firestore()
//        db.collection("Patient").getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Error fetching documents: \(error)")
//            } else {
//                if let snapshot = snapshot {
//                    self.patients = snapshot.documents.compactMap { doc -> Patient? in
//                        try? doc.data(as: Patient.self)
//                    }
//                }
//            }
//        }
//    }
//}
////-------------------------------------------------------
//// * MARK: -  Add Patient View  *
//// MARK: - Add Patient View
//
////-------------------------------------------------------
//// * MARK: -  Add Patient View  *
//// MARK: - Add Patient View
//
//
//
import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftSMTP

//struct EditPatientView: View  {
//    @Binding var isPresented: Bool
//    @Binding var patient: Patient?
//    @Binding var patients: [Patient]
//    @Binding var showSuccessMessage: Bool
//    @Binding var successMessage: String
//    @Binding var parentPresentation: Patient?
//
//    @State private var firstname: String = ""
//    @State private var lastname: String = ""
//    @State private var contactNumber: String = ""
//    @State private var email: String = ""
//    @State private var address: String = ""
//    @State private var gender: String = "Select Gender"
//    @State private var dob: Date = Date()
//    @State private var emergencyContact: String = ""
//    @State private var image: UIImage? = nil
//    @State private var showingImagePicker = false
//    @State private var showErrorMessage = false
//    @State private var errorMessage = ""
//    
//    
//    //    error variables
//        @State private var firstnameError: String? = nil
//        @State private var lastnameError: String? = nil
//        @State private var contactNumberError: String? = nil
//        @State private var emailError: String? = nil
//        
//    //    emergencyContact
//        @State private var  emergencyContactError: String? = nil
//
//    let genders = ["Select Gender", "Male", "Female", "Others"]
//
//    var isSaveButtonEnabled: Bool {
//        return !firstname.isEmpty && !lastname.isEmpty && !contactNumber.isEmpty && !email.isEmpty && !address.isEmpty && !gender.isEmpty && !emergencyContact.isEmpty
//    }
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                HStack {
//                    Button("Back") {
//                        isPresented = false
//                    }
//                    .foregroundColor(.blue)
//
//                    Spacer()
//
//                    Text("Edit Patient")
//                        .font(.headline)
//
//                    Spacer()
//
//                    Button("Save") {
//                        if validateFields() {
//                            updatePatientData(patient: patient, imageURL: patient?.imageURL)
//                        }
//                    }
//                    .disabled(!isSaveButtonEnabled)
//                    .foregroundColor(isSaveButtonEnabled ? .blue : .gray)
//                }
//                .padding()
//
//                Form {
//                    // Profile Picture Section
//                    Section(header: Text("Patient Profile Picture"))  {
//                        HStack {
//                            Spacer()
//                            Button(action: {
//                                showingImagePicker.toggle()
//                            }) {
//                                if let image = image {
//                                    Image(uiImage: image)
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fill)
//                                        .frame(width: 100, height: 100)
//                                        .clipShape(Circle())
//                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
//                                        .shadow(radius: 2)
//                                } else {
//                                    Image(systemName: "person.circle.fill")
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fill)
//                                        .frame(width: 100, height: 100)
//                                        .clipShape(Circle())
//                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
//                                        .shadow(radius: 2)
//                                }
//                            }
//                            .sheet(isPresented: $showingImagePicker) {
//                                PatientImagePicker(image: $image)
//                            }
//                            Spacer()
//                        }
//                    }
//
//                    // Name Section
//                    Section(header: Text("Name")) {
//                        HStack {
//                            Text("First Name")
//                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                            Spacer()
//                            TextField("First Name", text: $firstname)
//                                .multilineTextAlignment(.trailing)
//                                .onChange(of: firstname) { _ in
//                                    validateEntryFields()
//                                }
//                        }
//                        if let firstnameError = firstnameError {
//                            Text(firstnameError).foregroundColor(.red)
//                        }
//                        HStack {
//                            Text("Last Name")
//                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                            Spacer()
//                            TextField("Last Name", text: $lastname)
//                                .multilineTextAlignment(.trailing)
//                                .onChange(of: lastname) { _ in
//                                    validateEntryFields()
//                                }
//                        }
//                        if let lastnameError = lastnameError {
//                            Text(lastnameError).foregroundColor(.red)
//                        }
//                    }
//
//                    // Contact Information Section
//                    Section(header: Text("Contact Details")) {
//                        HStack {
//                            Text("Contact Number")
//                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                            Spacer()
//                            TextField("Contact Number", text: $contactNumber)
//                                .keyboardType(.numberPad)
//                                .multilineTextAlignment(.trailing)
//                                .onChange(of: contactNumber) { _ in
//                                    validateEntryFields()
//                                }
//                           
//                        }
//                        if let contactNumberError = contactNumberError {
//                            Text(contactNumberError).foregroundColor(.red)
//                        }
//
//                        HStack {
//                            Text("Email ID")
//                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                            Spacer()
//                            TextField("Email ID", text: $email)
//                                .keyboardType(.emailAddress)
//                                .multilineTextAlignment(.trailing)
//                                .onChange(of: email) { _ in
//                                    validateEntryFields()
//                                }
//                        }
//                            
////                            if isValidEmail(email) {
//                                if let emailError = emailError  {
//
//                                        Text(emailError)
//                                            .foregroundColor(.red)
//                                    }
//                                   
//                                    
//
//                                                HStack {
//                            Text("Emergency Contact")
//                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                            Spacer()
//                            TextField("Emergency Contact", text: $emergencyContact)
//                                .keyboardType(.numberPad)
//                                .multilineTextAlignment(.trailing)
//                                .onChange(of: emergencyContact) { _ in
//                                    validateEntryFields()
//                                }
//                            
//                        }
//                        if let emergencyContactError = emergencyContactError {
//                            Text(emergencyContactError).foregroundColor(.red)
//                        }
//                    }
//
//                    // Other Details Section
//                    Section(header: Text("Other Details")) {
//                        HStack {
//                            Text("Date of Birth")
//                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                            Spacer()
//                            DatePicker("", selection: $dob, displayedComponents: .date)
//                                .labelsHidden()
//                     
//                        } .frame(height: 30)
//                        
//                        // Gender Picker
//                        HStack {
//                            Text("Gender")
//                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                            Spacer()
//                            Menu {
//                                ForEach(genders, id: \.self) { gender in
//                                    Button(action: {
//                                        self.gender = gender
//                                    }) {
//                                        Text(gender)
//                                    }
//                                }
//                            } label: {
//                                HStack {
//                                    Text(gender)
//                                        .foregroundColor(.blue)
//                                    Image(systemName: "chevron.down")
//                                        .foregroundColor(.gray)
//                                }
//                                .padding()
//                                .background(Color.white)
//                                .frame(height: 30)
//                                .cornerRadius(8)
//                               
//                            }
//                        }
//
//                        HStack {
//                            Text("Address")
//                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                            Spacer()
//                            TextField("Address", text: $address)
//                                .multilineTextAlignment(.trailing)
//                               
//                        }
//                    }
//                }
//                .alert(isPresented: $showErrorMessage) {
//                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .onAppear {
//                if let patient = patient {
//                    firstname = patient.firstname
//                    lastname = patient.lastname
//                    contactNumber = patient.contactNumber
//                    email = patient.email
//                    address = patient.address
//                    gender = patient.gender
//                    dob = patient.dob
//                    emergencyContact = patient.emergencyContact
//                    if let imageURL = patient.imageURL {
//                        loadImage(from: imageURL)
//                    }
//                }
//            }
//        }
//    }
//
//    private func validateFields() -> Bool {
//        if firstname.isEmpty || lastname.isEmpty || contactNumber.isEmpty || email.isEmpty || address.isEmpty || gender.isEmpty || emergencyContact.isEmpty {
//            showErrorMessage = true
//            errorMessage = "All fields are mandatory."
//            return false
//        }
//        return true
//    }
//    private func validateEntryFields() -> Bool {
//        var valid = true
//        
//        if firstname == lastname {
//            firstnameError = "First name and last name cannot be the same."
//            lastnameError = "First name and last name cannot be the same."
//            valid = false
//        } else {
//            firstnameError = nil
//            lastnameError = nil
//        }
//        
//        if contactNumber.count != 10 {
//            contactNumberError = "Contact number must be 10 digits."
//            valid = false
//        } else {
//            contactNumberError = nil
//        }
//        
//        
//        
//        
//        if email.contains("@@") || email.contains("..") {
//            emailError = "Please Enter a Valid Email ID"
//            valid = false
//        } else if isValidEmail(email) == false {
//            emailError = "Please Enter a Valid Email ID"
//            valid = false
//        }
//        else {
//            emailError = nil
//        }
//        
//        if emergencyContact.count != 10 {
//            emergencyContactError = "Emergency Contact number must be 10 digits."
//            valid = false
//        } else {
//            emergencyContactError = nil
//        }
//        
//        
//        return valid
//    }
//
//    private func updatePatientData(patient: Patient?, imageURL: URL?) {
//        guard let patient = patient else { return }
//        
//        let db = Firestore.firestore()
//        let patientRef = db.collection("Patient").document(patient.id)
//        
//        patientRef.updateData([
//            "firstname": firstname,
//            "lastname": lastname,
//            "contactNumber": contactNumber,
//            "email": email,
//            "address": address,
//            "gender": gender,
//            "dob": dob,
//            "emergencyContact": emergencyContact,
//            "imageURL": imageURL?.absoluteString ?? patient.imageURL?.absoluteString ?? ""
//        ]) { err in
//            if let err = err {
//                print("Error updating document: \(err)")
//            } else {
//                print("Document successfully updated")
//                if let index = patients.firstIndex(where: { $0.id == patient.id }) {
//                    patients[index].firstname = firstname
//                    patients[index].lastname = lastname
//                    patients[index].contactNumber = contactNumber
//                    patients[index].email = email
//                    patients[index].address = address
//                    patients[index].gender = gender
//                    patients[index].dob = dob
//                    patients[index].emergencyContact = emergencyContact
//                    patients[index].imageURL = imageURL
//                }
//                successMessage = "Patient Updated Successfully"
//                showSuccessMessage = false
//                isPresented = false
//                parentPresentation = nil
//            }
//        }
//    }
//    
//    private func loadImage(from url: URL) {
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let data = data, let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    self.image = image
//                }
//            }
//        }
//        task.resume()
//    }
//}


//struct AddPatientView: View {
//    class EmailSender {
//            static let shared = EmailSender()
//            private init() {}
//            
//            func sendEmail(subject: String, body: String, to: String, from: String, smtpHost: String, smtpPort: Int, username: String, password: String) {
//                let smtp = SMTP(hostname: smtpHost, email: from, password: password, port: Int32(smtpPort), tlsMode: .requireSTARTTLS, tlsConfiguration: nil)
//                
//                let fromEmail = Mail.User(name: "Sender Name", email: from)
//                let toEmail = Mail.User(name: "Recipient Name", email: to)
//                
//                let mail = Mail(
//                    from: fromEmail,
//                    to: [toEmail],
//                    subject: subject,
//                    text: body
//                )
//                
//                smtp.send(mail) { (error) in
//                    if let error = error {
//                        print("Error sending email: \(error)")
//                    } else {
//                        print("Email sent successfully!")
//                    }
//                }
//            }
//        }
//    @Binding var isPresented: Bool
//    @Binding var patients: [Patient]
//    @Binding var showSuccessMessage: Bool
//    @Binding var successMessage: String
//
//    @State private var errorMessage = ""
//    @State private var firstname: String = ""
//    @State private var lastname: String = ""
//    @State private var contactNumber: String = ""
//    @State private var email: String = ""
//    @State private var address: String = ""
//    @State private var gender: String = "Select Gender"
//    @State private var dob: Date = Date()
//    @State private var emergencyContact: String = ""
//    @State private var image: UIImage? = nil
//    @State private var showingImagePicker = false
//    @State private var showErrorMessage = false
//    @State private var showGenderPicker = false
//    @State private var showCancelAlert = false
//    @State private var showDiscardMessage = false
//    
////    error variables
//    @State private var firstnameError: String? = nil
//    @State private var lastnameError: String? = nil
//    @State private var contactNumberError: String? = nil
//    @State private var emailError: String? = nil
//    
////    emergencyContact
//    @State private var  emergencyContactError: String? = nil
//
//    let genders = ["Select Gender", "Male", "Female", "Others"]
//
//    var isSaveButtonEnabled: Bool {
//        return !firstname.isEmpty && !lastname.isEmpty && !contactNumber.isEmpty && !email.isEmpty && !address.isEmpty && !gender.isEmpty && !emergencyContact.isEmpty
//    }
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                HStack {
//                    Button("Cancel") {
//                        showDiscardMessage.toggle()
//                    }
//                    .foregroundColor(.blue)
//
//                    Spacer()
//
//                    Text("Add Patient")
//                        .font(.headline)
//
//                    Spacer()
//
//                    Button("Save") {
//                        if validateFields() {
//                            addPatient()
//                        }
//                    }
//                    .disabled(!isSaveButtonEnabled)
//                    .foregroundColor(isSaveButtonEnabled ? .blue : .gray)
//                }
//                .padding()
////                .background(Color(.systemGray6))
//
//                Form {
//                    // Profile Picture Section
//                    Section(header: Text("Patient Profile Picture"))  {
//                        HStack {
//                            Spacer()
//                            Button(action: {
//                                showingImagePicker.toggle()
//                            }) {
//                                if let image = image {
//                                    Image(uiImage: image)
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fill)
//                                        .frame(width: 100, height: 100)
//                                        .clipShape(Circle())
//                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
//                                        .shadow(radius: 2)
//                                } else {
//                                    Image(systemName: "person.circle.fill")
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fill)
//                                        .frame(width: 100, height: 100)
//                                        .clipShape(Circle())
//                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
//                                        .shadow(radius: 2)
//                                }
//                            }
//                            .sheet(isPresented: $showingImagePicker) {
//                                PatientImagePicker(image: $image)
//                            }
//                            Spacer()
//                        }
//                    }
//
//                    // Name Section
//                    Section(header: Text("Name")) {
//                        TextField("First Name", text: $firstname)
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(8)
//                            .frame(height: 30)
//                            .padding(.horizontal)
//                            .padding(.bottom, 10)
//                            .onChange(of: firstname) { _ in
//                                validateEntryFields()
//                            }
//                        if let firstnameError = firstnameError {
//                            Text(firstnameError).foregroundColor(.red)
//                        }
//                        TextField("Last Name", text: $lastname)
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(8)
//                            .frame(height: 30)
//                            .padding(.horizontal)
//                            .padding(.bottom, 10)
//                            .onChange(of: lastname) { _ in
//                                validateEntryFields()
//                            }
//                        if let lastnameError = lastnameError {
//                            Text(lastnameError).foregroundColor(.red)
//                        }
//
//                    }
//
//                    // Contact Information Section
//                    Section(header: Text("Contact Details")) {
//                        TextField("Contact Number", text: $contactNumber)
//                            .keyboardType(.numberPad)
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(8)
//                            .frame(height: 30)
//                            .padding(.horizontal)
//                            .padding(.bottom, 10)
//                            .onChange(of: contactNumber) { _ in
//                                validateEntryFields()
//                            }
//                        if let contactNumberError = contactNumberError {
//                            Text(contactNumberError).foregroundColor(.red)
//                        }
//                        TextField("Email ID", text: $email)
//                            .keyboardType(.emailAddress)
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(8)
//                            .frame(height: 30)
//                            .padding(.horizontal)
//                            .padding(.bottom, 10)
//                            .onChange(of: email) { _ in
//                                validateEntryFields()
//                            }
//                            .overlay(HStack {
//                                                    Spacer()
//                                                    if email.isEmpty {
//                                                        Image(systemName: "")
//                                                            .padding()
//                                                    } else if isValidEmail(email) {
//                                                        Image(systemName: "checkmark.circle.fill")
//                                                            .foregroundColor(.green)
//                                                            .padding()
//                                                    } else {
//                                                        Image(systemName: "xmark.circle.fill")
//                                                            .foregroundColor(.red)
//                                                            .padding()
//                                                    }
//                                                })
//                        TextField("Emergency Contact", text: $emergencyContact)
//                            .keyboardType(.numberPad)
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(8)
//                            .frame(height: 30)
//                            .padding(.horizontal)
//                            .padding(.bottom, 10)
//                            .onChange(of: emergencyContact) { _ in
//                                validateEntryFields()
//                            }
//                        if let emergencyContactError = emergencyContactError {
//                            Text(emergencyContactError).foregroundColor(.red)
//                        }
//                    }
//
//                    // Other Details Section
//                    Section(header: Text("Other Details")) {
//                        DatePicker("Date of Birth", selection: $dob, displayedComponents: .date)
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(8)
//                            .frame(height: 30)
//                            .padding(.horizontal)
//                            .padding(.bottom, 10)
//                        
//                        // Gender Picker
//                        Menu {
//                            ForEach(genders, id: \.self) { gender in
//                                Button(action: {
//                                    self.gender = gender
//                                }) {
//                                    Text(gender)
//                                }
//                            }
//                        } label: {
//                            HStack {
//                                Text("Gender")
//                                    .foregroundColor(.black)
//                                Spacer()
//                                Text(gender)
//                                    .foregroundColor(.blue)
//                                Image(systemName: "chevron.down")
//                                    .foregroundColor(.gray)
//                            }
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(8)
//                            .frame(height: 30)
//                            .padding(.horizontal)
//                            .padding(.bottom, 10)
//                        }
//
//                        TextField("Address", text: $address)
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(8)
//                            .frame(height: 30)
//                            .padding(.horizontal)
//                            .padding(.bottom, 10)
//                    }
//                }
//                .alert(isPresented: $showErrorMessage) {
//                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .alert(isPresented: $showDiscardMessage) {
//                Alert(
//                    title: Text("Are you sure you want to discard this new contact?"),
//                    primaryButton: .destructive(Text("Discard Changes")) {
//                        isPresented = false
//                    },
//                    secondaryButton: .cancel()
//                )
//            }
//        }
//    }
//
//    private func validateFields() -> Bool {
//        if firstname.isEmpty || lastname.isEmpty || contactNumber.isEmpty || email.isEmpty || address.isEmpty || gender.isEmpty || emergencyContact.isEmpty {
//            showErrorMessage = true
//            errorMessage = "All fields are mandatory."
//            return false
//        }
//        return true
//    }
////    validateNameFields()
//    private func validateEntryFields() -> Bool {
//        var valid = true
//        
//        if firstname == lastname {
//            firstnameError = "First name and last name cannot be the same."
//            lastnameError = "First name and last name cannot be the same."
//            valid = false
//        } else {
//            firstnameError = nil
//            lastnameError = nil
//        }
//        
//        if contactNumber.count != 10 {
//            contactNumberError = "Contact number must be 10 digits."
//            valid = false
//        } else {
//            contactNumberError = nil
//        }
//        
//        
//        
//        
//        if email.contains("@@") || email.contains("..") {
//            emailError = "Email cannot contain consecutiv '@' or '.' characters."
//            valid = false
//        } else {
//            emailError = nil
//        }
//        
//        if emergencyContact.count != 10 {
//            emergencyContactError = "Emergency Contact number must be 10 digits."
//            valid = false
//        } else {
//            emergencyContactError = nil
//        }
//        
//        
//        return valid
//    }
//
//    private func addPatient() {
//        guard let image = image else {
//            errorMessage = "Please select an image."
//            showErrorMessage = true
//            return
//        }
//
//        let storage = Storage.storage()
//        let storageRef = storage.reference()
//        let imagesRef = storageRef.child("images/\(UUID().uuidString).jpg")
//        if let imageData = image.jpegData(compressionQuality: 0.8) {
//            let metadata = StorageMetadata()
//            metadata.contentType = "image/jpeg"
//            imagesRef.putData(imageData, metadata: metadata) { metadata, error in
//                guard metadata != nil else {
//                    return
//                }
//                imagesRef.downloadURL { url, error in
//                    guard let downloadURL = url else {
//                        return
//                    }
//                    savePatientData(imageURL: downloadURL)
//                }
//            }
//        }
//    }
//
//    private func savePatientData(imageURL: URL) {
//        let db = Firestore.firestore()
//        do {
//            Auth.auth().createUser(withEmail: email, password: "HMS@123") { authResult, error in
//                if let error = error {
//                    print("Error: \(error)")
//                } else {
//                    if let authResult = authResult {
//                        let userID = authResult.user.uid
//                        let newPatient = Patient(
//                            id: userID,
//                            firstname: firstname,
//                            lastname: lastname,
//                            contactNumber: contactNumber,
//                            email: email,
//                            address: address,
//                            gender: gender,
//                            dob: dob,
//                            imageURL: imageURL,
//                            emergencyContact: emergencyContact
//                        )
//                        let patientData = newPatient.toDictionary()
//                        do {
//                            try db.collection("Patient").document(userID).setData(patientData)
//                            patients.append(newPatient)
//                            successMessage = "Patient Added Successfully"
//                            showSuccessMessage = true
//                            isPresented = false
//                        } catch {
//                            print("Error setting patient data: \(error.localizedDescription)")
//                        }
//                    }
//                }
//            }
//        } catch let error {
//            print("Error writing patient to Firestore: \(error)")
//        }
//    }
//}
//
//
////-------------------------------------------------------
//// * MARK: -  Patient Details View  *
//// MARK: -  Patient Details View
//
//struct PatientDetailView: View {
//    var patient: Patient
//    var onBack: () -> Void
//    var onEdit: () -> Void
//
//    @State private var image: UIImage?
//    @Binding var isPresented: Patient?
//    @Binding var patients: [Patient]
//    @Binding var showSuccessMessage: Bool
//    @Binding var successMessage: String
//
//    @State private var isEditing = false
//    @State private var editedPatient: Patient?
//
//    var body: some View {
//        VStack(spacing: 20) {
//            HStack {
//                Button(action: {
//                    isPresented = nil
//                }) {
//                    Text("Back")
//                        .font(.system(size: 17, weight: .medium))
//                        .foregroundColor(.blue)
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 10)
////                        .background(Color.gray)
//                        .cornerRadius(20)
//                }
//                .padding(.horizontal)
//
//                Spacer()
//
//                Button(action: {
//                    editedPatient = patient
//                    isEditing.toggle()
//                }) {
//                    Text("Edit")
//                        .font(.system(size: 17, weight: .medium))
//                        .foregroundColor(.blue)
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 10)
//                        
////                        .background(Color.blue)
//                        .cornerRadius(20)
//                }
//                .padding(.horizontal)
//            }
//            .padding(.top, 20)
//
//            if let imageURL = patient.imageURL, let url = URL(string: imageURL.absoluteString) {
//                AsyncImage(url: url) { phase in
//                    switch phase {
//                    case .empty:
//                        ProgressView()
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 150, height: 150)
//                            .clipShape(Circle())
//                            .padding(.top, 20)
//                    case .failure:
//                        Image(systemName: "person.circle.fill")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 150, height: 150)
//                            .clipShape(Circle())
//                            .padding(.top, 20)
//                    @unknown default:
//                        EmptyView()
//                    }
//                }
//            } else {
//                Image(systemName: "person.circle.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 100, height: 100)
//                    .padding(.top, 20)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
//            }
//
//            Text("\(patient.firstname) \(patient.lastname)")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//
//            Form {
//                Section(header: Text("ID")) {
//                    Text(patient.id)
//                }
//                Section(header: Text("First Name")) {
//                    Text(patient.firstname)
//                }
//                Section(header: Text("Last Name")) {
//                    Text(patient.lastname)
//                }
//                Section(header: Text("Address")) {
//                    Text(patient.address)
//                }
//                Section(header: Text("Email")) {
//                    Text(patient.email)
//                }
//                Section(header: Text("Phone")) {
//                    Text(patient.contactNumber)
//                }
//                Section(header: Text("Gender")) {
//                    Text(patient.gender)
//                }
//                Section(header: Text("Date of Birth")) {
//                    Text("\(patient.dob, formatter: DateFormatter.shortDate)")
//                }
//                Section(header: Text("Emergency Contact")) {
//                    Text(patient.emergencyContact)
//                }
//            }
//            .listStyle(InsetGroupedListStyle())
//
//            Spacer()
//        }
//        .alert(isPresented: $showSuccessMessage) {
//            Alert(title: Text("Success"), message: Text(successMessage), dismissButton: .default(Text("OK")))
//        }
//        .sheet(isPresented: $isEditing) {
//            EditPatientView(
//                isPresented: $isEditing,
//                patient: $editedPatient,
//                patients: $patients,
//                showSuccessMessage: $showSuccessMessage,
//                successMessage: $successMessage,
//                parentPresentation: $isPresented
//            )
//        }
//    }
//}
//
//
////-------------------------------------------------------
//// * MARK: - Edit Patient  View  *
//// MARK: - Edit Patient  View
//
//struct EditPatientView: View {
//    @Binding var isPresented: Bool
//    @Binding var patient: Patient?
//    @Binding var patients: [Patient]
//    @Binding var showSuccessMessage: Bool
//    @Binding var successMessage: String
//    @Binding var parentPresentation: Patient?
//
//    @State private var firstname: String = ""
//    @State private var lastname: String = ""
//    @State private var contactNumber: String = ""
//    @State private var email: String = ""
//    @State private var address: String = ""
//    @State private var gender: String = "Male"
//    @State private var dob: Date = Date()
//    @State private var emergencyContact: String = ""
//    @State private var image: UIImage? = nil
//    @State private var showingImagePicker = false
//    @State private var showErrorMessage = false
//    @State private var errorMessage = ""
//   
//
//    let genders = ["Male", "Female", "Others"]
//
//    var body: some View {
//        VStack {
//            Form {
//                Section(header: Text("First Name")) {
//                    TextField("Enter First Name", text: $firstname)
//                }
//                Section(header: Text("Last Name")) {
//                    TextField("Enter Last Name", text: $lastname)
//                }
//                Section(header: Text("Contact No")) {
//                    TextField("Contact No", text: $contactNumber)
//                }
//                Section(header: Text("E-mail")) {
//                    TextField("Enter Email (Optional)", text: $email)
//                }
//               
//            
//                Section(header: Text("Address")) {
//                    TextField("Address", text: $address)
//                }
//                Section(header: Text("Gender")) {
//                    Picker("Select Gender", selection: $gender) {
//                        ForEach(genders, id: \.self) { gender in
//                            Text(gender)
//                        }
//                    }
//                    .pickerStyle(MenuPickerStyle())
//                }
//                Section(header: Text("DOB")) {
//                    DatePicker("Select Date", selection: $dob, displayedComponents: .date)
//                        .datePickerStyle(GraphicalDatePickerStyle())
//                }
//                Section(header: Text("Emergency Contact")) {
//                    TextField("Enter Emergency Contact", text: $emergencyContact)
//                }
//                Section {
//                    Button(action: {
//                        showingImagePicker.toggle()
//                    }) {
//                        Text("Choose Photo")
//                    }
//                    .sheet(isPresented: $showingImagePicker) {
//                        PatientImagePicker(image: $image)
//                    }
//                }
//            }
//            HStack {
//                Button("Back") {
//                    isPresented = false
//                }
//                .padding()
//                .background(Color.gray)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//                
//                Spacer()
//                
//                Button("Save") {
//                    if firstname.isEmpty || lastname.isEmpty || contactNumber.isEmpty || email.isEmpty || address.isEmpty || gender.isEmpty {
//                        showErrorMessage = true
//                    } else {
//                        updatePatientData(patient: patient, imageURL: patient?.imageURL)
//                    }
//                }
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//                .alert(isPresented: $showErrorMessage) {
//                    Alert(title: Text("Error"), message: Text("All fields are mandatory."), dismissButton: .default(Text("OK")))
//                }
//            }
//            .padding()
//            .onAppear {
//                if let patient = patient {
//                    firstname = patient.firstname
//                    lastname = patient.lastname
//                    contactNumber = patient.contactNumber
//                    email = patient.email
//                    address = patient.address
//                    gender = patient.gender
//                    dob = patient.dob
//                    emergencyContact = patient.emergencyContact
//                    if let imageURL = patient.imageURL {
//                        loadImage(from: imageURL)
//                    }
//                }
//            }
//        }
//    }
//    
//    private func updatePatientData(patient: Patient?, imageURL: URL?) {
//        guard let patient = patient else { return }
//        
//        let db = Firestore.firestore()
//        let patientRef = db.collection("Patient").document(patient.id)
//        
//        patientRef.updateData([
//            "firstname": firstname,
//            "lastname": lastname,
//            "contactNumber": contactNumber,
//            "email": email,
//            "address": address,
//            "gender": gender,
//            "dob": dob,
//            "emergencyContact": emergencyContact,
//            "imageURL": imageURL?.absoluteString ?? patient.imageURL?.absoluteString ?? ""
//        ]) { err in
//            if let err = err {
//                print("Error updating document: \(err)")
//            } else {
//                print("Document successfully updated")
//                if let index = patients.firstIndex(where: { $0.id == patient.id }) {
//                    patients[index].firstname = firstname
//                    patients[index].lastname = lastname
//                    patients[index].contactNumber = contactNumber
//                    patients[index].email = email
//                    patients[index].address = address
//                    patients[index].gender = gender
//                    patients[index].dob = dob
//                    patients[index].emergencyContact = emergencyContact
//                    patients[index].imageURL = imageURL
//                }
//                successMessage = "Patient Updated Successfully"
//                showSuccessMessage = false
//                isPresented = false
//                parentPresentation = nil
//            }
//        }
//    }
//    
//    private func loadImage(from url: URL) {
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let data = data, let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    self.image = image
//                }
//            }
//        }
//        task.resume()
//    }
//}
//
////-------------------------------------------------------
//// * MARK: -  Patient Image Picker  *
//// MARK: -  Patient Image Picker
//
//struct PatientImagePicker: UIViewControllerRepresentable {
//    @Binding var image: UIImage?
//
//    class Coordinator: NSObject, PHPickerViewControllerDelegate {
//        var parent: PatientImagePicker
//
//        init(parent: PatientImagePicker) {
//            self.parent = parent
//        }
//
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            picker.dismiss(animated: true)
//
//            guard let provider = results.first?.itemProvider else { return }
//
//            if provider.canLoadObject(ofClass: UIImage.self) {
//                provider.loadObject(ofClass: UIImage.self) { image, _ in
//                    self.parent.image = image as? UIImage
//                }
//            }
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
//
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        var configuration = PHPickerConfiguration()
//        configuration.filter = .images
//        let picker = PHPickerViewController(configuration: configuration)
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
//}
//
////-------------------------------------------------------
//// * MARK: -  Patient Card View  *
//// MARK: -  Patient Card View
//
////-------------------------------------------------------
//// * MARK: -  Patient Card View  *
//// MARK: -  Patient Card View
//
//struct PatientCardView: View {
//    var patient: Patient
//
//    var body: some View {
//        VStack(spacing: 17) {
//            
//            if let imageURL = patient.imageURL, let url = URL(string: imageURL.absoluteString) {
//                AsyncImage(url: url) { phase in
//                    switch phase {
//                    case .empty:
//                        ProgressView()
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 100, height: 100)
//                            .clipShape(Circle())
////                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
//                    case .failure:
//                        Image(systemName: "person.circle.fill")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 100, height: 100)
//                            .clipShape(Circle())
////                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
//                    @unknown default:
//                        EmptyView()
//                    }
//                }
//            } else {
//                Image(systemName: "person.circle.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 100, height: 100)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
//            }
//
//            Text("\(patient.firstname) \(patient.lastname)")
//                .font(.headline)
//                .foregroundColor(.primary)
//            Text(patient.contactNumber)
//                .font(.subheadline)
//                .foregroundColor(.black)
//        }
//        .frame(width: 200, height: 200) // Fixed width and height
//        .padding()
////        .background(Color(.systemGray6))
//        .cornerRadius(15)
//        .shadow(radius: 1.5)
//        .padding(.horizontal)
//        .padding(.vertical, 8)
//    }
//}
//
