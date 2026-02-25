import UIKit

final class OnboardingViewController: UIPageViewController {
    
    // MARK: - Private Properties
    private lazy var pages: [UIViewController] = {
        let content = [
            (image: "onboarding1", text: "Отслеживайте только то, что хотите"),
            (image: "onboarding2", text: "Даже если это не литры воды и йога")
        ]
        
        return content.map { item in
            let vc = UIViewController()
            
            let imageView = UIImageView()
            imageView.image = UIImage(named: item.image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = vc.view.bounds
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            vc.view.addSubview(imageView)
            
            let label = UILabel()
            label.text = item.text
            label.font = .systemFont(ofSize: 32, weight: .bold)
            label.textColor = .ypBlackDay
            label.numberOfLines = 0
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            vc.view.addSubview(label)
            
            return vc
        }
    }()
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = .ypBlackDay
        control.pageIndicatorTintColor = .ypGray
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhiteDay, for: .normal)
        button.backgroundColor = .ypBlackDay
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializers
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: true)
        }
        
        setupUIElements()
        setupLabelConstraints()
    }
    
    private func setupUIElements() {
        pageControl.numberOfPages = pages.count
        view.addSubview(pageControl)
        
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            continueButton.heightAnchor.constraint(equalToConstant: 60),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -24),
        ])
    }
    
    private func getBottomOffset() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        
        switch screenHeight {
        case 0...700:
            return -150
            
        default:
            return -270
        }
    }
    
    private func setupLabelConstraints() {
        let bottomOffset = getBottomOffset()
        
        for vc in pages {
            if let label = vc.view.subviews.first(where: { $0 is UILabel }) {
                label.translatesAutoresizingMaskIntoConstraints = false
                
                vc.view.constraints.forEach { constraint in
                    if constraint.firstItem === label || constraint.secondItem === label {
                        vc.view.removeConstraint(constraint)
                    }
                }
                
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
                    label.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
                    label.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: bottomOffset)
                ])
            }
        }
    }
    
    // MARK: - @objc Methods
    @objc private func continueButtonTapped() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        guard let window = view.window else { return }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = TabBarController()
        }
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        
        return pages[index + 1]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let currentVC = viewControllers?.first,
           let index = pages.firstIndex(of: currentVC) {
            pageControl.currentPage = index
        }
    }
}
