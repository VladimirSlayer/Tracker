import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        if false {
            window?.rootViewController = createTabBarController()
        } else {
            let onboardingVC = OnboardingViewController()
            onboardingVC.onFinish = { [weak self] in
                self?.window?.rootViewController = self?.createTabBarController()
            }
            window?.rootViewController = onboardingVC
        }

        window?.makeKeyAndVisible()
    }

    private func createTabBarController() -> UITabBarController {
        let trackersVC = TrackersViewController()
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "trackerTabIcon"), tag: 0)

        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "statisticTabIcon"), tag: 1)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [trackersVC, statisticsVC]

        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor.black.withAlphaComponent(0.3)

        tabBarController.view.addSubview(separatorView)

        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: tabBarController.tabBar.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: tabBarController.tabBar.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: tabBarController.tabBar.topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])

        return tabBarController
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
