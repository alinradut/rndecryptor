import SwiftUI
import RNCryptor

struct ContentView: View {
    // Decryption-related state:
    @State private var encryptedString: String = ""
    @State private var password: String = ""
    @State private var decryptedString: String = ""

    @State private var filePath: String = ""
    @State private var fileDecryptionMessage: String = ""

    // Toggle to show/hide the password:
    @State private var showPassword: Bool = false

    // Password management:
    @ObservedObject var passwordStore = PasswordStore()
    @State private var selectedPasswordId: UUID? = nil
    @State private var showingAddPasswordSheet = false

    // AppState is injected from our main App struct.
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 0) {
            // Left side: Decryption controls and password management.
            VStack(alignment: .leading, spacing: 20) {
                // MARK: Saved Passwords
                Text("Saved Passwords")
                    .font(.headline)

                HStack {
                    Picker("Saved Passwords", selection: $selectedPasswordId) {
                        Text("None").tag(UUID?.none)
                        ForEach(passwordStore.passwords) { entry in
                            Text(entry.name).tag(Optional(entry.id))
                        }
                    }
                    .onChange(of: selectedPasswordId) { newValue in
                        if let id = newValue,
                           let entry = passwordStore.passwords.first(where: { $0.id == id }) {
                            password = entry.password
                        }
                    }

                    // Button to add a new password.
                    Button(action: { showingAddPasswordSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Add a new password")

                    // Button to remove the selected password.
                    Button(action: removeSelectedPassword) {
                        Image(systemName: "minus.circle.fill")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Remove selected password")
                    .disabled(selectedPasswordId == nil)
                }

                Divider()

                // MARK: String Decryption
                Text("Decrypt String with RNCryptor")
                    .font(.headline)

                TextField("Encrypted String", text: $encryptedString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Password field with secure toggle:
                HStack {
                    Group {
                        if showPassword {
                            // Plain text field when showing the password.
                            TextField("Password", text: $password)
                        } else {
                            // SecureField when hiding the password.
                            SecureField("Password", text: $password)
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    // Toggle button with an "eye" icon.
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Toggle Password Visibility")
                }

                Button("Decrypt String") {
                    do {
                        decryptedString = try Decryptor.decryptString(encryptedString, password: password)
                    } catch {
                        decryptedString = "Decryption error: \(error.localizedDescription)"
                    }
                }

                Divider()

                // MARK: File Decryption
                Text("Decrypt File with RNCryptor")
                    .font(.headline)

                HStack {
                    TextField("Selected File Path", text: $filePath)
                        .disabled(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Select File") {
                        selectFile()
                    }
                }

                Button("Decrypt File") {
                    decryptAndPromptToSaveFile()
                }

                Text(fileDecryptionMessage)
                    .foregroundColor(.gray)

                Spacer()
            }
            .padding()
            .frame(minWidth: 300, maxHeight: .infinity)

            Divider()

            // Right side: Regular TextEditor showing decrypted text.
            TextEditor(text: Binding(
                get: { decryptedString },
                set: { _ in } // Keep read-only by ignoring edits.
            ))
            .font(.system(.body, design: .monospaced))
            .padding()
            .frame(minWidth: 200, maxWidth: .infinity, maxHeight: .infinity)
        }
        // Enable drag-and-drop anywhere in the window.
        .onDrop(of: ["public.file-url"], isTargeted: nil, perform: handleDrop)
        // Update filePath when a file is opened via Finder.
        .onChange(of: appState.openedFilePath) { newValue in
            if !newValue.isEmpty {
                filePath = newValue
            }
        }
        // Also check on appear in case the file was set before the view loaded.
        .onAppear {
            if !appState.openedFilePath.isEmpty {
                filePath = appState.openedFilePath
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingAddPasswordSheet) {
            AddPasswordView(passwordStore: passwordStore)
        }
    }

    // MARK: - File selection (via button)
    private func selectFile() {
        let dialog = NSOpenPanel()
        dialog.title = "Choose an encrypted file"
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false

        if dialog.runModal() == .OK {
            filePath = dialog.url?.path ?? ""
        }
    }

    // MARK: - Drag & Drop Handling
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (item, error) in
                    if let data = item as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            self.filePath = url.path
                        }
                    }
                }
                return true
            }
        }
        return false
    }

    // MARK: - Decrypt and Save (for files)
    private func decryptAndPromptToSaveFile() {
        guard !filePath.isEmpty else {
            fileDecryptionMessage = "Please select a file first."
            return
        }
        guard !password.isEmpty else {
            fileDecryptionMessage = "Please enter a password."
            return
        }

        do {
            // Decrypt file in memory.
            let decryptedData = try Decryptor.decryptFileData(at: filePath, with: password)

            var fileName = (filePath as NSString).lastPathComponent
            if (fileName as NSString).pathExtension == "enc" {
                fileName = (fileName as NSString).deletingPathExtension
            }
            else {
                fileName = fileName.appending(".decrypted")
            }

            // Prompt user for a save location.
            let savePanel = NSSavePanel()
            savePanel.title = "Save Decrypted File"
            savePanel.message = "Choose a location to save the decrypted file."
            savePanel.nameFieldStringValue = fileName

            if savePanel.runModal() == .OK, let saveURL = savePanel.url {
                try decryptedData.write(to: saveURL)
                fileDecryptionMessage = "File decrypted to: \(saveURL.path)"
            } else {
                fileDecryptionMessage = "Save was cancelled."
            }
        } catch {
            fileDecryptionMessage = "File decryption error: \(error.localizedDescription)"
        }
    }

    // MARK: - Remove Selected Password
    private func removeSelectedPassword() {
        if let id = selectedPasswordId {
            passwordStore.removePassword(with: id)
            selectedPasswordId = nil
            password = ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
