import UIKit

final class CategoryHeaderView: UICollectionReusableView {
    // MARK: - Static Properties
    static let identifier = "CategoryHeaderView"
    
    // MARK: - Private Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 19)
        label.textColor = .ypBlackDay
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
    func configure(withTitle title: String) {
        titleLabel.text = title
    }
    
    // MARK: - Public Methods
    private func setupUI() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
