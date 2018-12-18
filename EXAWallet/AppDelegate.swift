//
//  AppDelegate.swift
//  EXAWallet
//
//  Created by Igor Efremov on 12/06/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private var appCoordinator: AppCoordinatorProtocol?
    private var sequence = AppNavigationPointSequence(PincodeTimer())
    private var appInstruction  = AppInstructionLaunch() as AppInstructionLaunchProtocol
    private var appHidingScreen = HidingScreenPresenter() as HidingScreenPresenterProtocol

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if !setupFabric() {
            NSLog("Unable to setup Fabric")
        }
        
        setupAppearance()
        createWindow()

        let appRouter = AppRouter(window: window)
        let appNavigation = AppNavigation(appRouter: appRouter, sequence: sequence, hiddingScreen: appHidingScreen)
        appNavigation.onUpdatedAuthState = { state, type in
            switch type {
            case .bio:
                self.appInstruction.authBioState = state
            case .pin:
                self.appInstruction.authPinState = state
            }
        }

        appCoordinator = AppCoordinator(appNavigation: appNavigation)
        appCoordinator?.setupApp(with: .default)

        preparePushNotifications(for: application)

        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.02hhx", $0)}.joined()
        AppState.sharedInstance.saveToken(token)

        print(token)
    }
    
    func preparePushNotifications(for application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
            guard granted else {
                return
            }
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
    }


    func applicationWillResignActive(_ application: UIApplication) {
        appInstruction.instruction(required: {
            noop()
        }, optional: { [weak self] in
            self?.sequence.timer.saveQuitTime()
            self?.appHidingScreen.present(with: self?.window)
        })
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
        _ = AppState.sharedInstance.currentWallet?.close()
    }


    func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }


    func applicationDidBecomeActive(_ application: UIApplication) {
        appInstruction.instruction(required: { [weak self] in
            self?.appCoordinator?.setupApp(with: .regular)
        }, optional: { [weak self] in
            self?.appCoordinator?.updateUserFlow(with: .regular)
        })
    }


    func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

private extension AppDelegate {

    func createWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
    }
    
    func setupFabric() -> Bool {
        guard let fabricApiKey = EXACommon.loadApiKey(MoneroCommonConstants.fabricApiKeyPath) else {
            NSLog("Unable to get Fabric api key")
            return false
        }
        
        Crashlytics.start(withAPIKey: fabricApiKey.trim())
        
        return true
    }
    
    func setupAppearance() {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.mainColor
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UITextField.appearance().tintColor = UIColor.white
        UITextView.appearance().tintColor = UIColor.white
        
        setupTabBar()
        setupSwitch()
    }
    
    func setupTabBar() {
        UITabBar.appearance().barTintColor = UIColor.tabbarColor
        UITabBar.appearance().unselectedItemTintColor = UIColor.exaBlack
        UITabBar.appearance().tintColor = UIColor.mainColor
        UITabBar.appearance().isTranslucent = false
    }

    func setupSwitch() {
        UISwitch.appearance().onTintColor = UIColor.mainColor
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.badge, .sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("userNotificationCenter didReceive")
    }

}
