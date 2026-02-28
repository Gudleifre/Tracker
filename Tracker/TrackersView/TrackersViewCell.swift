import UIKit

final class TrackersViewCell: UICollectionViewCell {
    // MARK: - Static Properties
    static let identifier = "TrackersCell"
    
    // MARK: - Public Properties
    let plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .ypWhiteDay
        button.backgroundColor = .clear
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Private Properties
    private var trackerColor: UIColor?
    
    private let coloredView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhiteDay
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.text = "0 дней"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Public Methods
    func configure(with tracker: Tracker, isCompleted: Bool, completedDays: Int) {
        titleLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        coloredView.backgroundColor = tracker.color
        trackerColor = tracker.color
        
        let imageName = isCompleted ? "checkmark" : "plus"
        plusButton.setImage(UIImage(systemName: imageName), for: .normal)
        plusButton.backgroundColor = isCompleted ? tracker.color.withAlphaComponent(0.3) : tracker.color
        
        daysCountLabel.text = "\(completedDays) \(dayString(for: completedDays))"
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        contentView.addSubview(coloredView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(emojiLabel)
        
        contentView.addSubview(daysCountLabel)
        contentView.addSubview(plusButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            coloredView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coloredView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coloredView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coloredView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: coloredView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: coloredView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: coloredView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: coloredView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: coloredView.bottomAnchor, constant: -12),
            
            daysCountLabel.topAnchor.constraint(equalTo: coloredView.bottomAnchor, constant: 16),
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            plusButton.topAnchor.constraint(equalTo: coloredView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    private func dayString(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "дней"
        }
        
        switch lastDigit {
        case 1: return "день"
        case 2, 3, 4: return "дня"
        default: return "дней"
        }
    }
}
