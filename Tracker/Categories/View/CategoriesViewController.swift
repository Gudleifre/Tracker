import UIKit

final class CategoriesViewController: UIViewController {
    
    private let viewModel: CategoriesViewModel
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        tableView.rowHeight = 75
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.backgroundColor = .ypBlackDay
        button.layer.cornerRadius = 16
        button.setTitleColor(.ypWhiteDay, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private var currentDataSource: [CategoryViewModel] = []
    
    // MARK: - Initializers
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupPlaceholder()
        bindViewModel()
        
//        tableView.tableFooterView = UIView()
        
        updatePlaceholderVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadCategories()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteDay
      
        
        title = "Категория"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.hidesBackButton = true
        
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(placeholderView)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupConstraints() {
      NSLayoutConstraint.activate([
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
        
        addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        addButton.heightAnchor.constraint(equalToConstant: 60),
        
        placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        placeholderView.heightAnchor.constraint(equalToConstant: 200)
        
        ])
    }
    
    private func setupPlaceholder() {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .placeholderForTrackers)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderView.addSubview(imageView)
        placeholderView.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: placeholderView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: placeholderView.trailingAnchor, constant: -16),
            label.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor)
        ])
    }
    
    private func updatePlaceholderVisibility() {
        let isEmpty = currentDataSource.isEmpty
        placeholderView.isHidden = !isEmpty
    }
    
    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .loading:
                    break
                    
                    case .loaded(let categories):
                    self?.currentDataSource = categories
                    self?.tableView.reloadData()
                    self?.updatePlaceholderVisibility()
                    
                case .empty:
                    self?.currentDataSource = []
                    self?.tableView.reloadData()
                    self?.updatePlaceholderVisibility()
                    
                case .error(let message):
                    print("Error: \(message)")
                }
            }
        }
        
        viewModel.onDismissRequested = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - @objc Methods
    @objc private func addButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.onCategoryCreated = { [weak self] categoryName in
            self?.viewModel.addCategory(title: categoryName)
        }
        navigationController?.pushViewController(newCategoryVC, animated: true)
    }
}

//MARK: - Extensions
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier, for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let viewModel = currentDataSource[indexPath.row]
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == currentDataSource.count - 1
        
        cell.configure(with: viewModel, isFirst: isFirst, isLast: isLast)
        
        return cell
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.viewModel.doneButtonTapped()
        }
    }
}
