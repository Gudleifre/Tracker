import UIKit

final class OptionTableViewCell: UITableViewCell {
    // MARK: - Static Properties
    static let identifier = "optionCell"
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupAppearance() {
        backgroundColor = .ypBackgroundDay
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        textLabel?.font = .systemFont(ofSize: 17)
        textLabel?.textColor = .ypBlackDay
        detailTextLabel?.font = .systemFont(ofSize: 17)
        detailTextLabel?.textColor = .ypGray
    }
}
