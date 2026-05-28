import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct VaultView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VaultDocument.addedAt, order: .reverse) private var documents: [VaultDocument]
    @State private var gate = BiometricGate()
    @State private var showImporter = false
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if gate.isUnlocked {
                    vaultContent
                } else {
                    lockedView
                }
            }
            .staydayoScreenBackground()
            .navigationTitle("Vault")
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.pdf, .image, .data],
                allowsMultipleSelection: false
            ) { result in
                importFile(result)
            }
            .sheet(isPresented: $showAdd) {
                AddVaultDocumentSheet()
            }
        }
        .onAppear {
            if !gate.isUnlocked { gate.authenticate() }
        }
    }

    private var lockedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "faceid")
                .font(.system(size: 56))
                .foregroundStyle(StaydayoTheme.gold)
            Text("Vault is locked")
                .font(.title2.weight(.bold))
            Text("Use Face ID to access your travel documents stored in iCloud.")
                .font(.subheadline)
                .foregroundStyle(StaydayoTheme.inkMuted)
                .multilineTextAlignment(.center)
            Button("Unlock") { gate.authenticate() }
                .buttonStyle(StaydayoPrimaryButtonStyle())
                .padding(.horizontal, 40)
            DisclaimerBanner(compact: true)
                .padding(.horizontal, 24)
        }
        .padding(32)
    }

    private var vaultContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DisclaimerBanner(compact: true)

                ForEach(VaultCategory.allCases, id: \.self) { category in
                    let items = documents.filter { $0.category == category }
                    if !items.isEmpty {
                        categorySection(category, items: items)
                    }
                }

                if documents.isEmpty {
                    ContentUnavailableView(
                        "No documents",
                        systemImage: "folder",
                        description: Text("Store passports, visas, and bookings securely in iCloud.")
                    )
                    .padding(.vertical, 24)
                }

                HStack(spacing: 12) {
                    StaydayoGlassButton("Add document", systemImage: "plus") { showAdd = true }
                    StaydayoGlassButton("Import file", systemImage: "square.and.arrow.down") {
                        showImporter = true
                    }
                }

                expiryRemindersCard
                DisclaimerFooter()

                Button("Lock vault") { gate.lock() }
                    .font(.footnote)
                    .foregroundStyle(StaydayoTheme.inkMuted)
                    .frame(maxWidth: .infinity)
            }
            .padding(20)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAdd = true } label: { Image(systemName: "plus") }
            }
        }
    }

    private func categorySection(_ category: VaultCategory, items: [VaultDocument]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.systemImage)
                    .foregroundStyle(StaydayoTheme.goldDark)
                Text(category.label)
                    .font(.headline)
                Spacer()
                Text("\(items.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(StaydayoTheme.inkMuted)
            }
            ForEach(items) { doc in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(doc.title)
                            .font(.subheadline.weight(.medium))
                        if let expiry = doc.expiryDate {
                            Text("Expires \(expiry.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundStyle(expiryColor(expiry))
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 6)
            }
        }
        .padding(18)
        .staydayoGlassCard()
    }

    private var expiryRemindersCard: some View {
        let expiring = documents.compactMap { doc -> (VaultDocument, Int)? in
            guard let expiry = doc.expiryDate else { return nil }
            let days = Calendar.current.dateComponents([.day], from: Date(), to: expiry).day ?? 0
            return days <= 90 ? (doc, days) : nil
        }
        return VStack(alignment: .leading, spacing: 8) {
            Text("Expiry reminders")
                .font(.headline)
            if expiring.isEmpty {
                Text("No documents expiring in the next 90 days.")
                    .font(.caption)
                    .foregroundStyle(StaydayoTheme.inkMuted)
            } else {
                ForEach(expiring, id: \.0.id) { doc, days in
                    Text("\(doc.title) — \(days) days remaining")
                        .font(.subheadline)
                }
            }
        }
        .padding(18)
        .staydayoGlassCard()
    }

    private func expiryColor(_ date: Date) -> Color {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days < 30 { return StaydayoTheme.danger }
        if days < 90 { return StaydayoTheme.warning }
        return StaydayoTheme.inkMuted
    }

    private func importFile(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result, let url = urls.first else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: url) else { return }
        do {
            let fileName = try VaultStorageService.store(data: data, suggestedName: url.lastPathComponent)
            let doc = VaultDocument(title: url.deletingPathExtension().lastPathComponent, category: .other, storedFileName: fileName)
            modelContext.insert(doc)
            try? modelContext.save()
        } catch {}
    }
}

struct AddVaultDocumentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var category: VaultCategory = .passport
    @State private var hasExpiry = false
    @State private var expiryDate = Date()
    @State private var placeholderFileName = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                Picker("Category", selection: $category) {
                    ForEach(VaultCategory.allCases, id: \.self) { c in
                        Text(c.label).tag(c)
                    }
                }
                Toggle("Expiry date", isOn: $hasExpiry)
                if hasExpiry {
                    DatePicker("Expires", selection: $expiryDate, displayedComponents: .date)
                }
                TextField("Reference / filename note", text: $placeholderFileName)
                DisclaimerBanner(compact: true)
            }
            .navigationTitle("Add document")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let name = placeholderFileName.isEmpty ? "\(title).txt" : placeholderFileName
                        if let data = "Staydayo vault placeholder".data(using: .utf8),
                           let stored = try? VaultStorageService.store(data: data, suggestedName: name) {
                            let doc = VaultDocument(
                                title: title.isEmpty ? category.label : title,
                                category: category,
                                storedFileName: stored,
                                expiryDate: hasExpiry ? expiryDate : nil
                            )
                            modelContext.insert(doc)
                            try? modelContext.save()
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
