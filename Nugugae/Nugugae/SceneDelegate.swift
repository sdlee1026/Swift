//
//  SceneDelegate.swift
//  Nugugae
//
//  Created by 이성대 on 2020/09/16.
//  Copyright © 2020 이성대. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
               
        print("Scene Delegate willConnectTo", UserDefaults.standard.bool(forKey: "isLoggedIn"))
        UserDefaults.standard.set("false", forKey: "walk_isrunning")
        UserDefaults.standard.set("false", forKey: "walk_map_isrunning")
        print("first start, walk tracking, map_walkuser traking token -> false setting")

        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window.windowScene = windowScene
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            guard let vc = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "MainTapBarController") as? MainTapBarController else {
                        fatalError("Could not instantiate HomeVC!")
                    }
                    window.rootViewController = vc
                }
        else {
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
                fatalError("Could not instantiate HomeVC!")
            }
            window.rootViewController = vc
        }

        self.window = window

        window.makeKeyAndVisible()
        
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        print("app 아예 종료")
        
        if UserDefaults.standard.string(forKey: "walk_isrunning") == "true"{
            print("산책하기! 동작중 종료. 마무리 동작 수행")
            location_data.sharedInstance.stop_location(completion: { (ids) in
                sleep(3)
                print("3초 대기")
                print(ids)
            })
            
        }
        else{
            print("산책 동작 없이 그냥 종료")
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("app, 포어그라운드(실행화면 진입)")
        // 이때 실행화면이 walk_map인 경우에만 바꾸도록 바꿔야함, 아니 안바꿔도 될지도..?? 아직 잘 모르겠다..
        print("map_view의 유저 트래킹을 위한 토큰 -> true, 이제 포어그라운드에서 역할을 맏을것")
        UserDefaults.standard.set("true", forKey: "walk_map_isrunning")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        print("app, 백그라운드 진입")
        print("map_view의 유저 트래킹을 위한 토큰 -> false, 이제 포어그라운드에서 역할을 맏을것")
        UserDefaults.standard.set("false", forKey: "walk_map_isrunning")
        
        if UserDefaults.standard.string(forKey: "walk_isrunning") == "true"{
            print("산책하기 ON, 백그라운드에서도 위치 추적")
            location_data.sharedInstance.init_locationManager()
            // 산책하기 켜놓은 도중에 백그라운드 진입 하였을 경우.
        }
        else{
            print("산책하기 No, 백그라운드 위치 추적 x")
        }
    }


}

