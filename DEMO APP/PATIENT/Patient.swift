import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage



//-------------------------------------------------------
// ** MARK: -  Patient Data Model   ****
// MARK: -  Patient Data Model

struct Patient: Identifiable, Codable, Equatable {
    var id: String
    var firstname: String
    var lastname: String
    var contactNumber: String
    var email: String
    var address: String
    var gender: String
    var dob: Date
    var imageURL: URL?
    var emergencyContact: String
    
    init(id: String, firstname: String, lastname: String, contactNumber: String, email: String, address: String, gender: String, dob: Date, imageURL: URL? = nil, emergencyContact: String) {
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.contactNumber = contactNumber
        self.email = email
        self.address = address
        self.gender = gender
        self.dob = dob
        self.imageURL = imageURL
        self.emergencyContact = emergencyContact
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "firstname": firstname,
            "lastname": lastname,
            "contactNumber": contactNumber,
            "email": email,
            "address": address,
            "gender": gender,
            "dob": dob,
            "emergencyContact": emergencyContact
        ]
        if let imageURL = imageURL {
            dict["imageURL"] = imageURL.absoluteString
        }
        return dict
    }
}

//-------------------------------------------------------
// ** MARK: -  Patient View  ****
// MARK: -  Patient View

struct PatientView: View {
    @State private var searchText = ""
    @State private var patients = [Patient]()
    @State private var filterText = ""
    @State private var filterByContact = false
    @State private var showAddPatient = false
    @State private var showSuccessMessage = false
    @State private var successMessage = ""
    @State private var selectedPatient: Patient?
    @State private var showPatientDetail = false
    @State private var isEditing = false

    var filteredPatients: [Patient] {
        if searchText.isEmpty && filterText.isEmpty {
            return patients
        } else if filterByContact {
            return patients.filter { $0.contactNumber.contains(filterText) }
        } else {
            return patients.filter { $0.firstname.contains(searchText) }
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("Patients")
                    .font(.largeTitle)
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

                Button(action: {
                    filterByContact.toggle()
                }) {
                    Image(systemName: filterByContact ? "phone.fill" : "line.horizontal.3.decrease.circle")
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .popover(isPresented: $filterByContact) {
                    VStack {
                        TextField("Filter by Contact", text: $filterText)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        Button("Apply") {
                            filterByContact = false
                        }
                        .padding()
                    }
                    .padding()
                }

                Spacer()

                Button(action: {
                    showAddPatient.toggle()
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Patient")
                    }
                    .padding()
                    .background(Color(hex: "#E1654A"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .sheet(isPresented: $showAddPatient) {
                    AddPatientView(isPresented: $showAddPatient, patients: $patients, showSuccessMessage: $showSuccessMessage, successMessage: $successMessage)
                }
            }
            .padding(.horizontal)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 197), spacing: 20)]) {
                    ForEach(filteredPatients) { patient in
                        Button(action: {
                            selectedPatient = patient
                            showPatientDetail = true
                        }) {
                            PatientCardView(patient: patient)
                        }
                    }
                }
                .padding()
            }
            Spacer()
        }
        .padding()
        .background(Color(hex: "#EFBAB1").opacity(0.3))
        .alert(isPresented: $showSuccessMessage) {
            Alert(title: Text("Success"), message: Text(successMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear(perform: fetchPatients)
        .background(Color(hex: "#EFBAB1").opacity(0.3))
        .fullScreenCover(item: $selectedPatient) { patient in
            PatientDetailView(
                patient: patient,
                onBack: {
                    selectedPatient = nil
                },
                onEdit: {
                    selectedPatient = patient
                    isEditing = true
                },
                isPresented: $selectedPatient,
                patients: $patients,
                showSuccessMessage: $showSuccessMessage,
                successMessage: $successMessage
            )
            .navigationBarHidden(true)
            .sheet(isPresented: $isEditing) {
                EditPatientView(
                    isPresented: $isEditing,
                    patient: $selectedPatient,
                    patients: $patients,
                    showSuccessMessage: $showSuccessMessage,
                    successMessage: $successMessage,
                    parentPresentation: $selectedPatient
                )
                .onDisappear {
                    selectedPatient = nil
                }
            }
        }
    }

    private func fetchPatients() {
        let db = Firestore.firestore()
        db.collection("Patient").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
            } else {
                if let snapshot = snapshot {
                    self.patients = snapshot.documents.compactMap { doc -> Patient? in
                        try? doc.data(as: Patient.self)
                    }
                }
            }
        }
    }
}

//-------------------------------------------------------
// ** MARK: -  Add Patient View  ****
// MARK: - Add Patient View

struct AddPatientView: View {
    @Binding var isPresented: Bool
    @Binding var patients: [Patient]
    @Binding var showSuccessMessage: Bool
    @Binding var successMessage: String

    @State private var errorMessage = ""
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var contactNumber: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var gender: String = "Select"
    @State private var dob: Date = Date()
    @State private var emergencyContact: String = ""
    @State private var image: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var showErrorMessage = false

    let genders = ["Male", "Female", "Others"]

    var body: some View {
        VStack {
            Form {
                Section(header: Text("First Name")) {
                    TextField("Enter First Name", text: $firstname)
                }
                Section(header: Text("Last Name")) {
                    TextField("Enter Last Name", text: $lastname)
                }
                Section(header: Text("Contact No")) {
                    TextField("Contact No", text: $contactNumber)
                }
                Section(header: Text("E-mail")) {
                    TextField("Enter Email", text: $email)
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
                    DatePicker("Select Date", selection: $dob, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                Section(header: Text("Emergency Contact")) {
                    TextField("Enter Emergency Contact", text: $emergencyContact)
                }
                Section {
                    Button(action: {
                        showingImagePicker.toggle()
                    }) {
                        Text("Choose Photo")
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        PatientImagePicker(image: $image)
                    }
                }
            }
            HStack {
                Button("Back") {
                    isPresented = false
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
                
                Button("Save") {
                    if firstname.isEmpty || lastname.isEmpty || contactNumber.isEmpty || email.isEmpty || address.isEmpty || gender.isEmpty {
                        showErrorMessage = true
                    } else {
                        addPatient()
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .alert(isPresented: $showErrorMessage) {
                    Alert(title: Text("Error"), message: Text("All fields are mandatory."), dismissButton: .default(Text("OK")))
                }
            }
            .padding()
        }
    }
    
    private func addPatient() {
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
                    return
                }
                imagesRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        return
                    }
                    savePatientData(imageURL: downloadURL)
                }
            }
        }
    }
    
    private func savePatientData(imageURL: URL) {
        let db = Firestore.firestore()
        do {
            Auth.auth().createUser(withEmail: email, password: "HMS@123") { authResult, error in
                if let error = error {
                    print("error")
                } else {
                    if let authResult = authResult {
                        let userID = authResult.user.uid
                        let newPatient = Patient(id: userID,
                                                 firstname: firstname,
                                                 lastname: lastname,
                                                 contactNumber: contactNumber,
                                                 email: email,
                                                 address: address,
                                                 gender: gender,
                                                 dob: dob,
                                                 imageURL: imageURL,
                                                 emergencyContact: emergencyContact)
                        let patientData = newPatient.toDictionary()
                        do {
                            try db.collection("Patient").document(userID).setData(patientData)
                            patients.append(newPatient)
                            successMessage = "Patient Added Successfully"
                            showSuccessMessage = true
                            isPresented = false
                        } catch {
                            print("Error setting Patient data: \(error.localizedDescription)")
                        }
                    }
                }
            }
        } catch let error {
            print("Error writing patient to Firestore: \(error)")
        }
    }
}

//-------------------------------------------------------
// ** MARK: -  Patient Details View  ****
// MARK: -  Patient Details View

struct PatientDetailView: View {
    var patient: Patient
    var onBack: () -> Void
    var onEdit: () -> Void

    @State private var image: UIImage?
    @Binding var isPresented: Patient?
    @Binding var patients: [Patient]
    @Binding var showSuccessMessage: Bool
    @Binding var successMessage: String

    @State private var isEditing = false
    @State private var editedPatient: Patient?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Back") {
                    isPresented = nil
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
                
                Button("Edit") {
                    editedPatient = patient
                    isEditing.toggle()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
            }

            Text("\(patient.firstname) \(patient.lastname)")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Age: \(Calendar.current.dateComponents([.year], from: patient.dob, to: Date()).year ?? 0)")
                .font(.title2)
                .padding(.bottom)

            Form {
                Section(header: Text("ID")) {
                    Text(patient.id)
                }
                Section(header: Text("First Name")) {
                    Text(patient.firstname)
                }
                Section(header: Text("Last Name")) {
                    Text(patient.lastname)
                }
                Section(header: Text("Address")) {
                    Text(patient.address)
                }
                Section(header: Text("Email")) {
                    Text(patient.email)
                }
                Section(header: Text("Phone")) {
                    Text(patient.contactNumber)
                }
                Section(header: Text("Gender")) {
                    Text(patient.gender)
                }
                Section(header: Text("Date of Birth")) {
                    Text("\(patient.dob, formatter: DateFormatter.shortDate)")
                }
                Section(header: Text("Emergency Contact")) {
                    Text(patient.emergencyContact)
                }
            }

            Spacer()
        }
        .alert(isPresented: $showSuccessMessage) {
            Alert(title: Text("Success"), message: Text(successMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $isEditing) {
            EditPatientView(
                isPresented: $isEditing,
                patient: $editedPatient,
                patients: $patients,
                showSuccessMessage: $showSuccessMessage,
                successMessage: $successMessage,
                parentPresentation: $isPresented
            )
        }
    }
}

//-------------------------------------------------------
// ** MARK: - Edit Patient  View  ****
// MARK: - Edit Patient  View

struct EditPatientView: View {
    @Binding var isPresented: Bool
    @Binding var patient: Patient?
    @Binding var patients: [Patient]
    @Binding var showSuccessMessage: Bool
    @Binding var successMessage: String
    @Binding var parentPresentation: Patient?

    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var contactNumber: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var gender: String = "Male"
    @State private var dob: Date = Date()
    @State private var emergencyContact: String = ""
    @State private var image: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var showErrorMessage = false
    @State private var errorMessage = ""

    let genders = ["Male", "Female", "Others"]

    var body: some View {
        VStack {
            Form {
                Section(header: Text("First Name")) {
                    TextField("Enter First Name", text: $firstname)
                }
                Section(header: Text("Last Name")) {
                    TextField("Enter Last Name", text: $lastname)
                }
                Section(header: Text("Contact No")) {
                    TextField("Contact No", text: $contactNumber)
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
                    DatePicker("Select Date", selection: $dob, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                Section(header: Text("Emergency Contact")) {
                    TextField("Enter Emergency Contact", text: $emergencyContact)
                }
                Section {
                    Button(action: {
                        showingImagePicker.toggle()
                    }) {
                        Text("Choose Photo")
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        PatientImagePicker(image: $image)
                    }
                }
            }
            HStack {
                Button("Back") {
                    isPresented = false
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
                
                Button("Save") {
                    if firstname.isEmpty || lastname.isEmpty || contactNumber.isEmpty || email.isEmpty || address.isEmpty || gender.isEmpty {
                        showErrorMessage = true
                    } else {
                        updatePatientData(patient: patient, imageURL: patient?.imageURL)
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .alert(isPresented: $showErrorMessage) {
                    Alert(title: Text("Error"), message: Text("All fields are mandatory."), dismissButton: .default(Text("OK")))
                }
            }
            .padding()
            .onAppear {
                if let patient = patient {
                    firstname = patient.firstname
                    lastname = patient.lastname
                    contactNumber = patient.contactNumber
                    email = patient.email
                    address = patient.address
                    gender = patient.gender
                    dob = patient.dob
                    emergencyContact = patient.emergencyContact
                    if let imageURL = patient.imageURL {
                        loadImage(from: imageURL)
                    }
                }
            }
        }
    }
    
    private func updatePatientData(patient: Patient?, imageURL: URL?) {
        guard let patient = patient else { return }
        
        let db = Firestore.firestore()
        let patientRef = db.collection("Patient").document(patient.id)
        
        patientRef.updateData([
            "firstname": firstname,
            "lastname": lastname,
            "contactNumber": contactNumber,
            "email": email,
            "address": address,
            "gender": gender,
            "dob": dob,
            "emergencyContact": emergencyContact,
            "imageURL": imageURL?.absoluteString ?? patient.imageURL?.absoluteString ?? ""
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                if let index = patients.firstIndex(where: { $0.id == patient.id }) {
                    patients[index].firstname = firstname
                    patients[index].lastname = lastname
                    patients[index].contactNumber = contactNumber
                    patients[index].email = email
                    patients[index].address = address
                    patients[index].gender = gender
                    patients[index].dob = dob
                    patients[index].emergencyContact = emergencyContact
                    patients[index].imageURL = imageURL
                }
                successMessage = "Patient Updated Successfully"
                showSuccessMessage = true
                isPresented = false
                parentPresentation = nil
            }
        }
    }
    
    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
        task.resume()
    }
}

//-------------------------------------------------------
// ** MARK: -  Patient Image Picker  ****
// MARK: -  Patient Image Picker

struct PatientImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PatientImagePicker

        init(parent: PatientImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    self.parent.image = image as? UIImage
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}

//-------------------------------------------------------
// ** MARK: -  Patient Card View  ****
// MARK: -  Patient Card View

struct PatientCardView: View {
    var patient: Patient

    var body: some View {
        VStack {
            if let imageURL = patient.imageURL, let url = URL(string: imageURL.absoluteString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
            }

            Text("\(patient.firstname) \(patient.lastname)")
                .font(.headline)
            Text(patient.contactNumber)
                .font(.subheadline)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

//-------------------------------------------------------
// ** MARK: -  Extensions  ****
// MARK: -  Extensions

//extension DateFormatter {
//    static var shortDate: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        return formatter
//    }
//}
//
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 0, 0, 0)
//        }
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}
