//
//  Patient.swift
//  DEMO APP
//
//  Created by Sameer Verma on 08/07/24.
//

import SwiftUI
import PhotosUI
//import shared

var data = DataController.shared

struct PatientView: View {
    @State private var searchText = ""
    @State private var patients = data.getPatientArray()
    @State private var filterText = ""
    @State private var filterByContact = false
    @State private var showAddPatient = false
    @State private var showSuccessMessage = false
    @State private var successMessage = ""
    @State private var selectedPatient: Patient?

    var filteredPatients: [Patient] {
        if searchText.isEmpty && filterText.isEmpty {
            return patients
        } else if filterByContact {
            return patients.filter { $0.contactNumber.contains(filterText) }
        } else {
            return patients.filter { $0.name.contains(searchText) }
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
                        }) {
                            VStack {
                                if let image = patient.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 50)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: patient.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 50)
                                        .clipShape(Circle())
                                }

                                Text(patient.name)
                                    .font(.headline)
                                    .padding(.top)

                                Text(patient.contactNumber)
                                    .font(.subheadline)

                                Text("Age: \( Calendar.current.dateComponents([.year], from: patient.dob, to: Date()).year ?? 0) ")
                                    .font(.subheadline)
                                    .padding(.bottom)
                            }
                            .frame(width: 197, height: 226)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(36)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.all, 5)
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
        .sheet(item: $selectedPatient) { patient in
            PatientDetailView(patient: patient, isPresented: $selectedPatient, patients: $patients, showSuccessMessage: $showSuccessMessage, successMessage: $successMessage)
        }
    }
}

struct AddPatientView: View {
    @Binding var isPresented: Bool
    @Binding var patients: [Patient]
    @Binding var showSuccessMessage: Bool
    @Binding var successMessage: String

    @State private var name: String = ""
    @State private var contactNumber: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var gender: String = "Male"
    @State private var dob: Date = Date()
    @State private var emergencyContact: String = ""
    @State private var image: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var showErrorMessage = false

    let genders = ["Male", "Female", "Others"]

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Enter Name", text: $name)
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
                        ImagePicker(image: $image)
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
                    if name.isEmpty || contactNumber.isEmpty || email.isEmpty || address.isEmpty || gender.isEmpty {
                        showErrorMessage = true
                    } else {
                        let newPatient = Patient(
                            name: name,
                            contactNumber: contactNumber,
                            email: email,
                            address: address,
                            gender: gender,
                            dob: dob,
                            image: image,
                            emergencyContact: emergencyContact,
                            upcomingAppointments: nil,
                            previousDoctors: nil
                        )
                        patients.append(newPatient)
                        successMessage = "Patient Added Successfully"
                        showSuccessMessage = true
                        isPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showSuccessMessage = false
                        }
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
}

struct PatientDetailView: View {
    var patient: Patient
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

            if let image = patient.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
            } else {
                Image(systemName: patient.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
            }

            Text(patient.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Age: \(Calendar.current.dateComponents([.year], from: patient.dob, to: Date()).year ?? 0)")
                .font(.title2)
                .padding(.bottom)

            Form {
                Section(header: Text("ID")) {
                    Text(patient.id.uuidString)
                }
                Section(header: Text("Name")) {
                    Text(patient.name)
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
            EditPatientView(isPresented: $isEditing, patient: $editedPatient, patients: $patients, showSuccessMessage: $showSuccessMessage, successMessage: $successMessage, parentPresentation: $isPresented)
        }
    }
}

struct EditPatientView: View {
    @Binding var isPresented: Bool
    @Binding var patient: Patient?
    @Binding var patients: [Patient]
    @Binding var showSuccessMessage: Bool
    @Binding var successMessage: String
    @Binding var parentPresentation: Patient?

    @State private var name: String = ""
    @State private var contactNumber: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var gender: String = "Male"
    @State private var dob: Date = Date()
    @State private var emergencyContact: String = ""
    @State private var image: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var showErrorMessage = false

    let genders = ["Male", "Female", "Others"]

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Enter Name", text: $name)
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
                        ImagePicker(image: $image)
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
                    if name.isEmpty || contactNumber.isEmpty || email.isEmpty || address.isEmpty || gender.isEmpty {
                        showErrorMessage = true
                    } else {
                        guard let patient = patient else { return }
                        if let index = patients.firstIndex(where: { $0.id == patient.id }) {
                            patients[index].name = name
                            patients[index].contactNumber = contactNumber
                            patients[index].email = email
                            patients[index].address = address
                            patients[index].gender = gender
                            patients[index].dob = dob
                            patients[index].emergencyContact = emergencyContact
                            patients[index].image = image
                            successMessage = "Patient Edited Successfully"
                            showSuccessMessage = true
                            isPresented = false
                            parentPresentation = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                showSuccessMessage = false
                            }
                        }
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
                    name = patient.name
                    contactNumber = patient.contactNumber
                    email = patient.email
                    address = patient.address
                    gender = patient.gender
                    dob = patient.dob
                    emergencyContact = patient.emergencyContact
                    image = patient.image
                }
            }
        }
    }
}

//struct ImagePicker: UIViewControllerRepresentable {
//    class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
//        var parent: ImagePicker
//
//        init(parent: ImagePicker) {
//            self.parent = parent
//        }
//
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            parent.presentationMode.wrappedValue.dismiss()
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
//    @Environment(\.presentationMode) var presentationMode
//    @Binding var image: UIImage?
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

//extension DateFormatter {
//    static let shortDate: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        return formatter
//    }()
//}
//
//extension Color {
//    init(hex: String) {
//        let scanner = Scanner(string: hex)
//        _ = scanner.scanString("#")
//        var rgb: UInt64 = 0
//        scanner.scanHexInt64(&rgb)
//        let red = Double((rgb >> 16) & 0xFF) / 255.0
//        let green = Double((rgb >> 8) & 0xFF) / 255.0
//        let blue = Double(rgb & 0xFF) / 255.0
//        self.init(red: red, green: green, blue: blue)
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

