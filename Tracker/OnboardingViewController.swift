import UIKit

final class OnboardingViewController: UIViewController {

    private let pages: [OnboardingPage] = [
        OnboardingPage(imageName: "page1", text: "Отслеживайте только то, что хотите"),
        OnboardingPage(imageName: "page2", text: "Даже если это не литры воды и йога")
    ]

    private lazy var pageViewController: UIPageViewController = {
        let pvc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pvc.dataSource = self
        pvc.delegate = self
        return pvc
    }()

    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = pages.count
        control.currentPage = 0
        control.pageIndicatorTintColor = .systemGray3
        control.currentPageIndicatorTintColor = .black
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        return button
    }()

    var onFinish: (() -> Void)?

    private var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPageViewController()
        layout()
    }

    private func setupPageViewController() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)

        if let firstVC = viewController(at: 0) {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: false)
        }
    }

    private func layout() {
        view.addSubview(pageControl)
        view.addSubview(continueButton)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -24),

            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            continueButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func viewController(at index: Int) -> OnboardingPageContentViewController? {
        guard index >= 0 && index < pages.count else { return nil }
        let vc = OnboardingPageContentViewController(page: pages[index])
        vc.view.tag = index
        return vc
    }

    @objc private func didTapContinue() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        onFinish?()
    }
}

// MARK: - UIPageViewControllerDataSource & Delegate

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingPageContentViewController,
              let index = pages.firstIndex(of: currentVC.page) else { return nil }

        let previousIndex = (index - 1 + pages.count) % pages.count
        return OnboardingPageContentViewController(page: pages[previousIndex])
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingPageContentViewController,
              let index = pages.firstIndex(of: currentVC.page) else { return nil }

        let nextIndex = (index + 1) % pages.count
        return OnboardingPageContentViewController(page: pages[nextIndex])
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let visibleVC = pageViewController.viewControllers?.first as? OnboardingPageContentViewController,
              let index = pages.firstIndex(of: visibleVC.page) else { return }

        currentIndex = index
        pageControl.currentPage = index
    }
}



