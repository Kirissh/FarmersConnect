import SwiftUI
// import FirebaseCore // Temporarily removed

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // FirebaseApp.configure()
        return true
    }
}

struct FarmersConnectApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var vm: AppViewModel
    
    var body: some View {
        Group {
            if !vm.hasSeenOnboarding {
                OnboardingView()
            } else if vm.pendingRole == nil {
                RoleSelectionView()
            } else if !vm.isAuthenticated {
                LoginView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: vm.hasSeenOnboarding)
    }
}
