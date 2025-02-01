//
//  AddPasswordView.swift
//  RNDecryptor
//
//  Created by Alin Radut on 2/1/25.
//
import SwiftUI

struct AddPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var passwordStore: PasswordStore

    @State private var name: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Password")
                .font(.headline)

            TextField("Friendly Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.horizontal)

                Spacer()

                Button("Save") {
                    guard !name.isEmpty, !password.isEmpty else { return }
                    passwordStore.addPassword(name: name, password: password)
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

struct AddPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        AddPasswordView(passwordStore: PasswordStore())
    }
}
