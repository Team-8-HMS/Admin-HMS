import SwiftUI
import FirebaseAuth

struct LoginMain: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State var isForgetPasswordTapped = false
    @State var loginButtonTapped = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Password validation checks
    private var isPasswordLengthValid: Bool {
        return password.count >= 8
    }
    
    private var containsUppercase: Bool {
        let uppercase = CharacterSet.uppercaseLetters
        return password.rangeOfCharacter(from: uppercase) != nil
    }
    
    private var containsLowercase: Bool {
        let lowercase = CharacterSet.lowercaseLetters
        return password.rangeOfCharacter(from: lowercase) != nil
    }
    
    private var containsNumber: Bool {
        let numbers = CharacterSet.decimalDigits
        return password.rangeOfCharacter(from: numbers) != nil
    }
    
    private var containsSpecialCharacter: Bool {
        let specialCharacters = CharacterSet.punctuationCharacters
        return password.rangeOfCharacter(from: specialCharacters) != nil
    }
    
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
                    
                    // Foreground content
                    VStack {
                        Spacer()
                        
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
                            .frame(width: 750) // Explicitly set text color
                            .overlay(
                                HStack {
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
                                }
                            )
                            .padding(.top, 20)
                        
                        if !isValidEmail(email) && !email.isEmpty {
                            Text("Please enter a valid email address.")
                                .font(.footnote)
                                .foregroundColor(.red)
                        }
                        
                        // Password SecureField
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .disableAutocorrection(true)
                            .foregroundColor(.black)
                            .frame(width: 750) // Explicitly set text color
                        
                        // Password validation checks
                        
                        
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
                                .frame(width: 750)
                                .background(Color.blue)
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
            }
            .navigationBarHidden(true) // Hide navigation bar in the login view
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    
    //Login Message when the login button tapped
    func login() {
        print("Func")
        Auth.auth().signIn(withEmail: email, password: password) { firebaseResult, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                alertMessage = "Email or password is incorrect. Please try again."
                showAlert = true
            } else {
                print("Else")
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


#Preview{
    LoginMain()
}
