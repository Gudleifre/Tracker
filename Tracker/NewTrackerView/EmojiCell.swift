import UIKit

final class EmojiCell: UICollectionViewCell {
    // MARK: - Static Properties
    static let identifier = "EmojiCell"
    
    // MARK: - Private Properties
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Public Methods
    func configure(with emoji: String, isSelected: Bool = false) {
        emojiLabel.text = emoji
        
        if isSelected {
            contentView.backgroundColor = .ypLightGray
        } else {
            contentView.backgroundColor = .clear
        }
    }
    
    override var isSelected: Bool {
        didSet {
            configure(with: emojiLabel.text ?? "", isSelected: isSelected)
        }
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        contentView.addSubview(emojiLabel)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
