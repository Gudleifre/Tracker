import UIKit

final class CategoryTableViewCell: UITableViewCell {
    static let identifier = "CategoryTableViewCell"
    
    // MARK: - Private Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .ypBlue
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Public Methods
    func configure(with viewModel: CategoryViewModel, isFirst: Bool, isLast: Bool) {
        titleLabel.text = viewModel.title
        checkmarkImageView.isHidden = !viewModel.isSelected
        
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        if isFirst && isLast {
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                               .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            contentView.layer.maskedCorners = []
        }
        
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .ypBackgroundDay
        selectionStyle = .none
       
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -8),
            
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24)
            ])
    }
}
