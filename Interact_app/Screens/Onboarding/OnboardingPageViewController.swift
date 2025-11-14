//////
//////  OnboardingPageViewController.swift
//////  Interact_app
//////
//////  Created by admin56 on 09/11/25.
//////
////
////import UIKit
////
////class OnboardingPageViewController: UIPageViewController {
////
////    override func viewDidLoad() {
////        super.viewDidLoad()
////
////        // Do any additional setup after loading the view.
////    }
////
////
////    /*
////    // MARK: - Navigation
////
////    // In a storyboard-based application, you will often want to do a little preparation before navigation
////    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
////        // Get the new view controller using segue.destination.
////        // Pass the selected object to the new view controller.
////    }
////    */
////
////}
//
//import UIKit
//
//class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
//
//    private var pages = [UIViewController]()
//    private let pageControl = UIPageControl()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        dataSource = self
//        delegate = self
//
//        setupPages()
//        setupPageControl()
//    }
//
//    private func setupPages() {
//        let page1 = Onboarding1ViewController(nibName: "Onboarding1ViewController", bundle: nil)
//        page1.imageName = "business-team-is-solving-business-puzzle 1"
//        page1.titleText = "Find & Team Up"
//        page1.descText = "Connect with teammates based on skills and interests, form teams, and prepare for upcoming competitions together."
//        page1.showSkipButton = true
//
//        let page2 = Onboarding1ViewController(nibName: "Onboarding1ViewController", bundle: nil)
//        page2.imageName = "business-way-to-success 2"
//        page2.titleText = "Compete & Grow"
//        page2.descText = "Participate in hackathons and events, track your progress, and showcase your achievements as you level up."
//        page2.showSkipButton = true
//
//        let page3 = Onboarding1ViewController(nibName: "Onboarding1ViewController", bundle: nil)
//        page3.imageName = "Calendar"
//        page3.titleText = "Host Events"
//        page3.descText = "Create events, open registrations, and manage RSVPs smoothly - no spreadsheets or manual coordination needed."
//        page3.showSkipButton = false
//
//        pages = [page1, page2, page3]
//        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
//    }
//
//    private func setupPageControl() {
//        pageControl.numberOfPages = pages.count
//        pageControl.currentPage = 0
//        pageControl.translatesAutoresizingMaskIntoConstraints = false
//        pageControl.currentPageIndicatorTintColor = .label
//        pageControl.pageIndicatorTintColor = .lightGray
//        view.addSubview(pageControl)
//
//        NSLayoutConstraint.activate([
//            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
//            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
//        ])
//    }
//
//    // MARK: - Data Source
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
//        return pages[index - 1]
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
//        return pages[index + 1]
//    }
//
//    // MARK: - Delegate
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        guard completed, let currentVC = viewControllers?.first, let index = pages.firstIndex(of: currentVC) else { return }
//        pageControl.currentPage = index
//
//        // When user reaches the last page, swipe will auto-navigate to login
//        if index == pages.count - 1 {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.completeOnboarding()
//            }
//        }
//    }
//
//    private func completeOnboarding() {
//        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
//        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
//        navigationController?.setViewControllers([loginVC], animated: true)
//    }
//}


//
//  OnboardingPageViewController.swift
//  Interact_app
//
//  Created by admin56 on 09/11/25.
//

//
//  OnboardingPageViewController.swift
//  Interact_app
//
//  Created by admin56 on 09/11/25.
//

//
//  OnboardingPageViewController.swift
//  Interact_app
//
//  Created by admin56 on 09/11/25.
//

import UIKit

// MARK: - Custom Page Control (Pill Style)
class CustomPageControl: UIView {

    var numberOfPages: Int = 0 {
        didSet { setupDots() }
    }

    var currentPage: Int = 0 {
        didSet { updateDots() }
    }

    var currentPageColor: UIColor = .label
    var otherPageColor: UIColor = .lightGray

    private var dots: [UIView] = []
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
    }

    private func setupStackView() {
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func setupDots() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dots.removeAll()

        for _ in 0..<numberOfPages {
            let dot = UIView()
            dot.layer.cornerRadius = 5
            dot.backgroundColor = otherPageColor
            stackView.addArrangedSubview(dot)
            dots.append(dot)

            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 10),
                dot.heightAnchor.constraint(equalToConstant: 10)
            ])
        }
        updateDots()
    }

    private func updateDots() {
        for (index, dot) in dots.enumerated() {
            if index == currentPage {
                UIView.animate(withDuration: 0.25) {
                    dot.backgroundColor = self.currentPageColor
                    dot.layer.cornerRadius = 5
                    dot.constraints.first { $0.firstAttribute == .width }?.constant = 30 // elongated pill
                    self.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.25) {
                    dot.backgroundColor = self.otherPageColor
                    dot.layer.cornerRadius = 5
                    dot.constraints.first { $0.firstAttribute == .width }?.constant = 10 // small circle
                    self.layoutIfNeeded()
                }
            }
        }
    }
}

// MARK: - Onboarding Page View Controller
class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    private var pages = [UIViewController]()
    private let customPageControl = CustomPageControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        setupPages()
        setupPageControl()
        setupTapGesture()
    }

    // MARK: - Setup Pages
    private func setupPages() {
        let page1 = Onboarding1ViewController(nibName: "Onboarding1ViewController", bundle: nil)
        page1.imageName = "business-team-is-solving-business-puzzle 1"
        page1.titleText = "Find & Team Up"
        page1.descText = "Connect with teammates based on skills - form teams, and prepare for upcoming competitions together."
        page1.showSkipButton = true

        let page2 = Onboarding1ViewController(nibName: "Onboarding1ViewController", bundle: nil)
        page2.imageName = "business-way-to-success 2"
        page2.titleText = "Compete & Grow"
        page2.descText = "Participate in hackathons and events, track your progress, and showcase your achievements as you level up."
        page2.showSkipButton = true

        let page3 = Onboarding1ViewController(nibName: "Onboarding1ViewController", bundle: nil)
        page3.imageName = "Calendar"
        page3.titleText = "Host Events"
        page3.descText = "Create events, open registrations, and manage RSVPs smoothly - no manual coordination needed."
        page3.showSkipButton = false

        pages = [page1, page2, page3]
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
    }

    // MARK: - Setup Custom Page Control (Bottom-Left)
    private func setupPageControl() {
        customPageControl.numberOfPages = pages.count
        customPageControl.currentPage = 0
        customPageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customPageControl)

        NSLayoutConstraint.activate([
            customPageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            customPageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            customPageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    // MARK: - Tap Gesture for Next Page
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func handleScreenTap() {
        guard let currentVC = viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentVC) else { return }

        if currentIndex < pages.count - 1 {
            // Go to next page
            let nextVC = pages[currentIndex + 1]
            setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
            customPageControl.currentPage = currentIndex + 1
        } else {
            // Last page → complete onboarding
            completeOnboarding()
        }
    }

    // MARK: - Data Source
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }

    // MARK: - Delegate
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = viewControllers?.first,
              let index = pages.firstIndex(of: currentVC) else { return }

        customPageControl.currentPage = index

        if index == pages.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.completeOnboarding()
            }
        }
    }

    // MARK: - Complete Onboarding
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        navigationController?.setViewControllers([loginVC], animated: true)
    }
}
