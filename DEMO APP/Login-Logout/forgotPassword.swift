import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isMailSent = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ZStack {
                // Background image
                Image("loginbac")
                    .resizable()
                    .scaledToFit()
                    .edgesIgnoringSafeArea(.all)
                
                ZStack {
                    Image("card")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .frame(width: 800, height: 800)
                    
                    VStack {
                        Spacer()
                        
                        // Header text
                        Text("Forgot your password?")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .padding(.bottom, 10)
                        
                        // Email TextField
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                            .foregroundColor(.black)
                            .frame(width: 750)
                        
                        // Reset Password button
                        Button(action: sendMail) {
                            Text("Reset Your Password")
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 700)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .padding(.top, 60)
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitle("")
        }
        .navigationBarTitle("")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"), action: {
                    if isMailSent {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            )
        }
    }

    func sendMail() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                alertTitle = "Error"
                alertMessage = error.localizedDescription
                isMailSent = false
            } else {
                alertTitle = "Mail Sent"
                alertMessage = "A password reset email has been sent to \(email)."
                isMailSent = true
            }
            showAlert = true
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
