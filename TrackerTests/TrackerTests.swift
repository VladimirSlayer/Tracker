import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testTrackersViewControllerSnapshot() {
        let trackersVC = TrackersViewController()
        let navVC = UINavigationController(rootViewController: trackersVC)
        
        let tabBarVC = UITabBarController()
        tabBarVC.viewControllers = [navVC]
        tabBarVC.selectedViewController = navVC

        // Создаем окно вручную
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = tabBarVC
        window.makeKeyAndVisible()

        // Даем времени на отрисовку
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        
        assertSnapshot(of: tabBarVC, as: .image(on: .iPhone13))
    }
}
