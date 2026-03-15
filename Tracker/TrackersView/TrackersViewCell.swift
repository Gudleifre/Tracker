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
        label.textColor = .ypWhiteStatic
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
        label.text = NSLocalizedString("days_count", comment: "Days count")
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
        
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("days_count", comment: "Number of days"),
            completedDays
        )
        
        daysCountLabel.text = daysString
    }
    
    func createPreview(with tracker: Tracker) -> UIView {
        let preview = UIView(frame: CGRect(x: 0, y: 0, width: 167, height: 90))
        preview.backgroundColor = tracker.color
        preview.layer.cornerRadius = 16
        preview.clipsToBounds = true
        
        let emojiLabel = UILabel(frame: CGRect(x: 12, y: 12, width: 28, height: 28))
        emojiLabel.text = tracker.emoji
        emojiLabel.font = .systemFont(ofSize: 14)
        emojiLabel.textAlignment = .center
        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = 14
        emojiLabel.clipsToBounds = true
        preview.addSubview(emojiLabel)
        
        let titleLabel = UILabel(frame: CGRect(x: 12, y: 48, width: 143, height: 34))
        titleLabel.text = tracker.title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        preview.addSubview(titleLabel)
        
        return preview
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
}
