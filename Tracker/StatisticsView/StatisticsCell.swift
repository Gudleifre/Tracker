import UIKit

final class StatisticsCell: UITableViewCell {
    // MARK: - Static Properties
    static let identifier = "StatisticsCell"
    
    // MARK: - Private Properties
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhiteDay
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    // MARK: - Overrides Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.frame = containerView.bounds
            }
        }
    }
    
    // MARK: - Public Methods
    func configure(value: String, title: String) {
        valueLabel.text = value
        titleLabel.text = title
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(valueLabel)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
        
        DispatchQueue.main.async {
            self.addGradientBorder()
        }
    }
    
    private func addGradientBorder() {
        let gradient = CAGradientLayer()
        gradient.frame = containerView.bounds
        gradient.colors = [
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor,
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 16).cgPath
        shape.lineWidth = 2
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        gradient.mask = shape
        
        containerView.layer.addSublayer(gradient)
    }
    
   
}
