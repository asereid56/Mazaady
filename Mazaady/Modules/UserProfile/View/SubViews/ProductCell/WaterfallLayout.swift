//
//  WaterfallLayout.swift
//  Mazaady
//
//  Created by Aser Eid on 25/04/2025.
//

import UIKit

protocol WaterfallLayoutDelegate: AnyObject {
    /// Asks delegate for the height of the item at indexPath, given the itemWidth
    func collectionView(_ collectionView: UICollectionView,
                        heightForItemAt indexPath: IndexPath,
                        withWidth itemWidth: CGFloat) -> CGFloat
}

class WaterfallLayout: UICollectionViewLayout {
    weak var delegate: WaterfallLayoutDelegate?

    /// Configurable number of columns & spacing
    var numberOfColumns: Int = 3
    var cellPadding: CGFloat = 8

    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let cv = collectionView else { return 0 }
        let insets = cv.contentInset
        return cv.bounds.width - (insets.left + insets.right)
    }

    override func prepare() {
        super.prepare()
        guard cache.isEmpty, let cv = collectionView else { return }

        // Calculate column width
        let columnWidth = (contentWidth - cellPadding * CGFloat(numberOfColumns - 1)) / CGFloat(numberOfColumns)
        // Track y-offset for each column
        var columnHeights = Array<CGFloat>(repeating: 0, count: numberOfColumns)

        var xOffset: [CGFloat] = []
        for col in 0..<numberOfColumns {
            xOffset.append(CGFloat(col) * (columnWidth + cellPadding))
        }

        var column = 0
        let itemCount = cv.numberOfItems(inSection: 0)

        for item in 0..<itemCount {
            let indexPath = IndexPath(item: item, section: 0)

            // Ask delegate for height
            let itemHeight = delegate?.collectionView(cv,
                                                      heightForItemAt: indexPath,
                                                      withWidth: columnWidth) ?? 0

            let frame = CGRect(x: xOffset[column],
                               y: columnHeights[column],
                               width: columnWidth,
                               height: itemHeight)

            let insetFrame = frame.insetBy(dx: 0, dy: 0)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            // Update contentHeight & columnHeight
            contentHeight = max(contentHeight, frame.maxY)
            columnHeights[column] = columnHeights[column] + itemHeight + cellPadding

            // Move to shortest column
            if let minHeight = columnHeights.min(),
               let minIndex = columnHeights.firstIndex(of: minHeight) {
                column = minIndex
            }
        }
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath)
        -> UICollectionViewLayoutAttributes? {
        return cache.first { $0.indexPath == indexPath }
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
        contentHeight = 0
    }
}
