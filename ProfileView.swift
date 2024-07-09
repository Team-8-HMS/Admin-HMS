//
//  ProfileView.swift
//  HMS_admin_Demo_02
//
//  Created by Sameer Verma on 04/07/24.
//
import FirebaseAuth
import SwiftUI

struct logoutview: View {
    @State var isLoggedOut = false
    @State private var showAlert = false

    var body: some View {
        
            VStack {
                Text("Do you Want to Logout ?")
                    .font(.largeTitle)
                    .padding()

                Button(action: {
                    // Handle logout action
                    logout()
                }) {
                    Text("Logout")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.top, 20)
                }

                NavigationLink(destination: LoginMain()
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true),
                               isActive: $isLoggedOut) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Logged Out"),
                    message: Text("You have been logged out from the app."),
                    dismissButton: .default(Text("OK"), action: {
                        isLoggedOut = true
                    })
                )
            
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            showAlert = true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

#Preview {
    logoutview()
}
