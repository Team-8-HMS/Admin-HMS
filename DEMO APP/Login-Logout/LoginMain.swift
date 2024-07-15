import SwiftUI
import FirebaseAuth

struct LoginMain: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State var isForgetPasswordTapped = false
    @State var loginButtonTapped = false
    @State private var passwordError: String?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isPasswordVisible = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background image
                Image("loginbac")
                    .resizable()
                    .scaledToFit()
                    .edgesIgnoringSafeArea(.all)
                Color(hex: "#EFBAB1")
                    .opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Welcome!")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(Color(red: 255/255, green: 101/255, blue: 74/255))
                        .padding(.top, 250)
                    
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
                        .frame(width: 500)
                        .overlay(
                            HStack {
                                Spacer()
                                if email.isEmpty {
                                    Image(systemName: "")
                                        .padding()
                                } else if isValidEmail(email) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .padding(.trailing, 16)
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .padding(.trailing, 16)
                                }
                            }
                        )
                        .padding(.top, 20)
                    
                    if !isValidEmail(email) && !email.isEmpty {
                        Text("Please enter a valid email address.")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                    
                    // Password TextField with visibility toggle
                    ZStack {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                                .autocapitalization(.none)
                                .padding(.horizontal, 20)
                                .disableAutocorrection(true)
                                .foregroundColor(.black)
                                .frame(width: 500)
                                .overlay(
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            isPasswordVisible.toggle()
                                        }) {
                                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 16)
                                        }
                                    }
                                )
                        } else {
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .disableAutocorrection(true)
                                .foregroundColor(.black)
                                .frame(width: 500)
                                .overlay(
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            isPasswordVisible.toggle()
                                        }) {
                                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 16)
                                        }
                                    }
                                )
                        }
                    }
                    
                    if let passwordError = passwordError {
                        Text(passwordError)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding([.leading, .top], 4)
                    }
                    
                    NavigationLink(destination: ForgotPasswordView(), isActive: $isForgetPasswordTapped) {
                        EmptyView()
                    }
                    
                    // Forgot Password button
                    Button(action: {
                        // Handle forgot password action
                        isForgetPasswordTapped = true
                        print("Forgot Password button tapped")
                        ForgotPasswordView()
                    }) {
                        Text("Forgot Password?")
                            .foregroundColor(.blue)
                            .padding(.top, 10)
                    }
                    
                    // Login button
                    Button(action: {
                        // Handle login action
                        login()
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 350)
                            .background(Color.black)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    NavigationLink(destination: ContentView()
                                    .navigationBarBackButtonHidden(true)
                                    .navigationBarHidden(true),
                                   isActive: $loginButtonTapped) {
                        EmptyView()
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true) // Hide navigation bar in the login view
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func validatePassword() {
        if password.isEmpty {
            passwordError = "Password is required."
        } else {
            passwordError = nil
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { firebaseResult, error in
            if let error = error {
                alertMessage = "Email or password is incorrect. Please try again."
                showAlert = true
            } else {
                fetchAppointments()
                loginButtonTapped = true
            }
        }
    }
}

func isValidEmail(_ email: String) -> Bool {
    let allowedDomains = [
        "gmail.com", "yahoo.com", "hotmail.com", "outlook.com", "icloud.com",
        "aol.com", "mail.com", "zoho.com", "protonmail.com", "gmx.com"
    ]
    let emailRegEx = "^[A-Z0-9a-z._%+-]+@(" + allowedDomains.joined(separator: "|") + ")$"
    let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

#Preview {
    LoginMain()
}
