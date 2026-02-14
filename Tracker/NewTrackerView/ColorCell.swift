import UIKit

final class ColorCell: UICollectionViewCell {
    // MARK: - Static Properties
    static let identifier = "ColorCell"
    
    // MARK: - Private Properties
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.clear.cgColor
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    func configure(with color: UIColor, isSelected: Bool = false) {
        colorView.backgroundColor = color
        selectionView.isHidden = !isSelected
        
        if isSelected {
            selectionView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        }
    }
    
    override var isSelected: Bool {
        didSet {
            configure(with: colorView.backgroundColor ?? .clear, isSelected: isSelected)
        }
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        contentView.addSubview(colorView)
        contentView.addSubview(selectionView)
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            
            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionView.widthAnchor.constraint(equalToConstant: 52),
            selectionView.heightAnchor.constraint(equalToConstant: 52),
            ])
    }
}
