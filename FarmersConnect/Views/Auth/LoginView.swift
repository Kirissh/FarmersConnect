import SwiftUI

struct LoginView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    @State private var selectedLanguage = "English"
    @State private var showForgotPassword = false
    @State private var showOTPSheet = false
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    @State private var showChangeRole = false
    
    var role: UserRole { vm.pendingRole ?? .customer }
    var roleColor: Color { role == .farmer ? Theme.primary : Theme.accent }
    var roleIcon: String { role == .farmer ? "tractor.fill" : "cart.fill" }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [roleColor.opacity(0.08), Theme.background],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Role banner
                    HStack {
                        Button(action: { withAnimation { vm.pendingRole = nil; vm.db.savePendingRole(nil) } }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                Text("Change Role")
                            }
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(roleColor)
                        }
                        Spacer()
                        Picker("Language", selection: $selectedLanguage) {
                            Text("English").tag("English")
                            Text("Hindi").tag("Hindi")
                            Text("Marathi").tag("Marathi")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .foregroundColor(Theme.textLight)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(roleColor.opacity(0.12))
                                .frame(width: 100, height: 100)
                            Image(systemName: roleIcon)
                                .font(.system(size: 44))
                                .foregroundColor(roleColor)
                        }
                        .padding(.top, 30)
                        
                        Text("Sign in as \(role.rawValue)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(role == .farmer
                            ? "Access your farm dashboard and listings"
                            : "Shop fresh produce from local farmers")
                            .font(.subheadline)
                            .foregroundColor(Theme.textLight)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 36)
                    
                    // Form Card
                    VStack(spacing: 20) {
                        // Phone
                        HStack {
                            HStack(spacing: 6) {
                                Text("🇮🇳")
                                Text("+91")
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.textDark)
                            }
                            .padding(.trailing, 4)
                            Divider().frame(height: 22)
                            TextField("Phone number", text: $phoneNumber)
                                .keyboardType(.numberPad)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        
                        // Password
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .frame(width: 20)
                            SecureField("Password", text: $password)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        
                        // Error
                        if let error = errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button(action: { showForgotPassword = true }) {
                                Text("Forgot Password?")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(roleColor)
                            }
                        }
                        
                        // Login button
                        Button(action: handleLogin) {
                            Group {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Log In")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(roleColor)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        
                        // Divider or
                        HStack {
                            Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                            Text("OR")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                            Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                        }
                        
                        // OTP Login
                        Button(action: { showOTPSheet = true }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("Login with OTP")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(roleColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(roleColor.opacity(0.1))
                            .cornerRadius(14)
                        }
                        
                        // New user note
                        HStack {
                            Text("New to Farmers Connect?")
                                .font(.subheadline)
                                .foregroundColor(Theme.textLight)
                            Button(action: handleLogin) {
                                Text("Sign Up")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(roleColor)
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(color: Color.black.opacity(0.08), radius: 20, y: 10)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(roleColor: roleColor)
        }
        .sheet(isPresented: $showOTPSheet) {
            OTPLoginView(roleColor: roleColor)
        }
    }
    
    private func handleLogin() {
        guard !phoneNumber.isEmpty else {
            errorMessage = "Please enter your phone number."
            return
        }
        guard phoneNumber.count == 10 || phoneNumber.count > 7 else {
            errorMessage = "Enter a valid 10-digit phone number."
            return
        }
        errorMessage = nil
        isLoading = true
        vm.requestOTP(phoneNumber: phoneNumber)
        // Simulate checking network
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            if vm.needsOTPVerification {
                showOTPSheet = true
            } else if let err = vm.authError {
                errorMessage = err
            }
        }
    }
}

// MARK: - Forgot Password Sheet
struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    let roleColor: Color
    @State private var phone = ""
    @State private var sent = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "lock.rotation")
                    .font(.system(size: 60))
                    .foregroundColor(roleColor)
                    .padding(.top, 32)
                
                Text(sent ? "OTP Sent!" : "Forgot Password?")
                    .font(.title2).fontWeight(.bold)
                
                Text(sent
                    ? "We've sent a reset OTP to +91 \(phone). Enter it to reset your password."
                    : "Enter your registered phone number and we'll send you a reset OTP.")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                if !sent {
                    HStack {
                        Text("+91").fontWeight(.semibold)
                        Divider().frame(height: 20)
                        TextField("Phone number", text: $phone)
                            .keyboardType(.numberPad)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                    .padding(.horizontal)
                    
                    Button(action: { withAnimation { sent = true } }) {
                        Text("Send OTP")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(roleColor)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                } else {
                    Button(action: { dismiss() }) {
                        Text("Back to Login")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(roleColor)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - OTP Login Sheet
struct OTPLoginView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    let roleColor: Color
    @State private var phone = ""
    @State private var otp = ""
    @State private var otpSent = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "phone.badge.checkmark.fill")
                    .font(.system(size: 60))
                    .foregroundColor(roleColor)
                    .padding(.top, 32)
                
                Text(otpSent ? "Enter OTP" : "Login with OTP")
                    .font(.title2).fontWeight(.bold)
                
                if !otpSent {
                    HStack {
                        Text("+91").fontWeight(.semibold)
                        Divider().frame(height: 20)
                        TextField("Phone number", text: $phone)
                            .keyboardType(.numberPad)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                    .padding(.horizontal)
                    
                    Button(action: {
                        vm.requestOTP(phoneNumber: phone)
                        withAnimation { otpSent = true }
                    }) {
                        Text("Send OTP")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(roleColor)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                } else {
                    Text("Enter the 6-digit OTP sent to +91 \(phone)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    TextField("6-digit OTP", text: $otp)
                        .keyboardType(.numberPad)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(14)
                        .padding(.horizontal)
                    
                    Button(action: {
                        vm.verifyOTPAndLogin(otp: otp)
                        dismiss()
                    }) {
                        Text("Verify & Login")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(roleColor)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("OTP Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
