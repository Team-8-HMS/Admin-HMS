import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var selectedItem: String? = "Overview"
    @State private var showLogoutConfirmation = false
    @State private var isLoggedOut = false
    let items = ["Overview", "Patient", "Appointment" ,"Doctor List","Lab-Test","Request","Logout"]
    let icons = ["doc.richtext", "person", "calendar", "stethoscope","creditcard","person.fill.checkmark","person.icloud.fill" ]
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationSplitView {
                    List {
                        ForEach(Array(zip(items, icons)), id: \.0) { item, icon in
                            HStack {
                                Image(systemName: icon)
                                    .foregroundColor(selectedItem == item ? .white : .primary)
                                Text(item)
                                    .foregroundColor(selectedItem == item ? .white : .primary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                selectedItem == item ? Color(UIColor(red: 225 / 255, green: 101 / 255, blue: 74 / 255, alpha: 1)) : Color.clear
                            )
                            .cornerRadius(10)
                            .padding(.horizontal, 0)
                            .listRowBackground(Color.clear)
                            .onTapGesture {
                                if item == "Logout" {
                                    showLogoutConfirmation = true
                                } else {
                                    selectedItem = item
                                }
                            }
                        }
                    }
                    .navigationTitle("Admin")
//                    .navigationBarBackButtonHidden(true)
                    .listStyle(PlainListStyle())
                    .background(Color.white)
                    .padding(EdgeInsets(top: 80, leading: 0, bottom: 30, trailing: 10))
                }
                detail: {
                    if let selectedItem = selectedItem {
                        destinationView(for: selectedItem)
                            .background(Color.gray.opacity(0.1)) // background color for detail view
                    } else {
                        Text("Select an item")
                    }
                }
                .alert(isPresented: $showLogoutConfirmation) {
                    Alert(
                        title: Text("Logout"),
                        message: Text("Are you sure you want to log out?"),
                        primaryButton: .destructive(Text("OK"), action: {
                            // Handle logout action
                            logout()
                        }),
                        secondaryButton: .cancel()
                    )
                }
                
                NavigationLink(destination: LoginMain()
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true),
                               isActive: $isLoggedOut) {
                    EmptyView()
                }
            }
//            .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    func destinationView(for menuItem: String) -> some View {
        switch menuItem {
        case "Overview": // Case 1 call
            OverviewView()
        case "Patient" : // Case 2
            PatientView()
        case "Doctor List":
            DoctorView()
        
        case "Lab-Test":
            PricingView()
        case "Request":
            RequestView()
        case "Logout":
            Text("Logging out...")
            
        case "Appointment":
            AppointmentView()
        default:
            Text("Unknown selection")
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedOut = true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
