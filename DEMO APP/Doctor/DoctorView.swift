import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Foundation

struct Doctor: Identifiable, Codable, Equatable {
    var id = UUID()
    var idNumber: Int
    var name: String
    var contactNo: String
    var email: String
    var address: String
    var gender: String
    var dob: Date
    var degree: String
    var department: String
    var status: Bool
    var entryTime: Date
    var exitTime: Date
    var visitingFees: Int
    var imageURL: URL?
    var workingDays: [String]
    var yearsOfExperience: Int
    
    init(idNumber: Int, name: String, contactNo: String, email: String, address: String, gender: String, dob: Date, degree: String, department: String, status: Bool, entryTime: Date, exitTime: Date, visitingFees: Int, imageURL: URL?, workingDays: [String], yearsOfExperience: Int) {
        self.idNumber = idNumber
        self.name = name
        self.contactNo = contactNo
        self.email = email
        self.address = address
        self.gender = gender
        self.dob = dob
        self.degree = degree
        self.department = department
        self.status = status
        self.entryTime = entryTime
        self.exitTime = exitTime
        self.visitingFees = visitingFees
        self.imageURL = imageURL
        self.workingDays = workingDays
        self.yearsOfExperience = yearsOfExperience
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
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
            "workingDays": workingDays,
            "yearsOfExperience": yearsOfExperience
        ]
        
        if let imageURL = imageURL {
            dict["imageURL"] = imageURL.absoluteString
        }
        
        return dict
    }
    
    var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date())
        return ageComponents.year ?? 0
    }
}

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
            return doctors.filter { $0.name.contains(searchText) }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Doctors List")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.top)
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
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                Spacer()
                
                Button(action: {
                    showAddDoctor.toggle()
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Doctor")
                    }
                    .padding()
                    .background(Color(hex: "#E1654A"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .sheet(isPresented: $showAddDoctor) {
                    AddDoctorView(isPresented: $showAddDoctor, doctors: $doctors, showSuccessMessage: $showSuccessMessage, successMessage: $successMessage)
                }
            }
            
            ScrollView { // Added ScrollView
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 197), spacing: 20)]) { // Arranged Doctors in a Horizontal Row
                    ForEach(filteredDoctors) { doctor in
                        Button(action: {
                            selectedDoctor = doctor
                            showDoctorDetail = true
                        }) {
                            VStack {
                                AsyncImage(url: doctor.imageURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100) // Image size
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                                } placeholder: {
                                    ProgressView()
                                }
                                Text(doctor.name)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .padding(.top)
                                    .foregroundColor(.black)
                                
                                Text(doctor.department)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                
                                Text("ID: \(doctor.idNumber)")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .padding(.bottom)
                                
                                Text("Entry: \(DateFormatter.timeFormatter.string(from: doctor.entryTime))")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                
                                Text("Exit: \(DateFormatter.timeFormatter.string(from: doctor.exitTime))")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .padding(.bottom)
                            }
                            .frame(width: 197, height: 300)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(36)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.all, 5)
                        }
                        .sheet(isPresented: $showDoctorDetail) {
                            if let doctor = selectedDoctor {
                                DoctorDetailView(doctor: doctor, onBack: {
                                    selectedDoctor = nil
                                    showDoctorDetail = false
                                }, onRemove: {
                                    if let index = doctors.firstIndex(of: doctor) {
                                        removeDoctorFromFirestore(doctor: doctor)
                                        doctors.remove(at: index)
                                        selectedDoctor = nil
                                        showDoctorDetail = false
                                    }
                                }, onEdit: {
                                    isEditing = true
                                })
                                .sheet(isPresented: $isEditing) {
                                    EditDoctorView(isPresented: $isEditing, doctor: $selectedDoctor, doctors: $doctors, showSuccessMessage: $showSuccessMessage, successMessage: $successMessage)
                                        .onDisappear {
                                            selectedDoctor = nil
                                            showDoctorDetail = false
                                        }
                                }
                            }
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
        .background(Color(hex: "#EFBAB1").opacity(0.3))
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

struct AddDoctorView: View {
    @Binding var isPresented: Bool
    @Binding var doctors: [Doctor]
    @Binding var showSuccessMessage: Bool
    @Binding var successMessage: String
    
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
    @State private var visitingFees : Int = 0
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
        self._idNumber = State(initialValue: Self.generateUniqueRandomID())
    }
    
    var body: some View {
        NavigationView {
            Form {
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
                }
                Section(header: Text("Years of Experience")) {
                    TextField("Enter Years of Experience", value: $yearsOfExperience, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
                Section {
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
        }.sheet(isPresented: $showDobPicker) {
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
                    // Uh-oh, an error occurred!
                    return
                }
                // You can also access to download URL after upload.
                imagesRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    saveDoctorData(imageURL: downloadURL)
                }
            }
        }
    }
    
    private func saveDoctorData(imageURL: URL) {
        let newDoctor = Doctor(idNumber: idNumber,
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
        
        let db = Firestore.firestore()
        do {
            Auth.auth().createUser(withEmail: email, password: String(idNumber))
            // Convert Doctor instance to dictionary
            let doctorData = newDoctor.toDictionary()
            
            // Save data to Firestore
            try db.collection("Doctors").document("\(newDoctor.id)").setData(doctorData)
            
            // Update local doctors array
            doctors.append(newDoctor)
            successMessage = "Doctor Added Successfully"
            showSuccessMessage = true
            isPresented = false
        } catch let error {
            print("Error writing doctor to Firestore: \(error)")
        }
    }
    
    private static func generateUniqueRandomID() -> Int {
        var newID: Int
        repeat {
            newID = Int.random(in: 100000...999999)
        } while generatedIDs.contains(newID)
        
        generatedIDs.insert(newID)
        return newID
    }
}

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

struct DoctorDetailView: View {
    var doctor: Doctor
    var onBack: () -> Void
    var onRemove: () -> Void
    var onEdit: () -> Void
    
    @State private var image: UIImage?
    @State private var isEditing = false
    @State private var editedDoctor: Doctor?
    
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
                }
                Section(header: Text("Years of Experience")) {
                    TextField("Enter Years of Experience", value: $yearsOfExperience, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
                Section {
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

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }
            
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                self.parent.image = image as? UIImage
            }
        }
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let green = Double((rgbValue & 0xff00) >> 8) / 255.0
        let blue = Double(rgbValue & 0xff) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
