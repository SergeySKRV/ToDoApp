//
//  TodoCell.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import UIKit

final class TodoCell: UITableViewCell {
    static let reuseIdentifier = "TodoCell"

    private let statusImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let dividerView = UIView()
    private let textStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.attributedText = nil
        descriptionLabel.attributedText = nil
        dateLabel.text = nil
        statusImageView.image = nil
    }

    func configure(with viewModel: TaskListCellViewModel) {
        if viewModel.isCompleted {
            titleLabel.attributedText = NSAttributedString(
                string: viewModel.title,
                attributes: [
                    .foregroundColor: AppColors.secondaryText,
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue
                ]
            )

            descriptionLabel.attributedText = NSAttributedString(
                string: viewModel.description,
                attributes: [
                    .foregroundColor: AppColors.tertiaryText,
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue
                ]
            )

            statusImageView.image = UIImage(systemName: "checkmark.circle")
            statusImageView.tintColor = AppColors.accent
        } else {
            titleLabel.attributedText = NSAttributedString(
                string: viewModel.title,
                attributes: [
                    .foregroundColor: AppColors.primaryText
                ]
            )

            descriptionLabel.attributedText = NSAttributedString(
                string: viewModel.description,
                attributes: [
                    .foregroundColor: AppColors.secondaryText
                ]
            )

            statusImageView.image = UIImage(systemName: "circle")
            statusImageView.tintColor = AppColors.tertiaryText
        }

        dateLabel.text = viewModel.createdAtText
    }

    private func setupUI() {
        backgroundColor = AppColors.background
        contentView.backgroundColor = AppColors.background
        selectionStyle = .none

        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.contentMode = .scaleAspectFit
        statusImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)

        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.lineBreakMode = .byTruncatingTail

        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = AppColors.tertiaryText

        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = AppColors.divider

        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .fill
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(descriptionLabel)
        textStack.addArrangedSubview(dateLabel)

        contentView.addSubview(statusImageView)
        contentView.addSubview(textStack)
        contentView.addSubview(dividerView)

        NSLayoutConstraint.activate([
            statusImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            statusImageView.widthAnchor.constraint(equalToConstant: 24),
            statusImageView.heightAnchor.constraint(equalToConstant: 24),

            textStack.leadingAnchor.constraint(equalTo: statusImageView.trailingAnchor, constant: 12),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textStack.bottomAnchor.constraint(equalTo: dividerView.topAnchor, constant: -12),

            dividerView.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
