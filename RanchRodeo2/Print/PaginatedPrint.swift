import SwiftUI
import CoreGraphics

/// A multi-page print document expressed as a repeating `header`, a list of `rows`,
/// and an optional `footer` that appears only on the last page.
///
/// `render()` measures the intrinsic height of the header, footer, and every row,
/// then packs rows onto pages so content is never clipped at the page boundary —
/// the flaw in the old "fixed number of rows per page + fixed-height frame" approach,
/// which silently cut off anything that overflowed a full page.
@MainActor
struct PaginatedPrintDocument {
    var pageSize = CGSize(width: 612, height: 792) // US Letter @ 72 DPI
    /// Safe margin on all sides. 0.5" keeps content clear of the printer's
    /// non-printable border (the secondary cause of the clipped-bottom bug).
    var margin: CGFloat = 36
    /// Vertical gap between the header, each row, and the footer.
    var spacing: CGFloat = 8
    let header: AnyView
    let rows: [AnyView]
    var footer: AnyView? = nil

    private var contentWidth: CGFloat { pageSize.width - margin * 2 }
    private var usableHeight: CGFloat { pageSize.height - margin * 2 }

    func render() -> Data? {
        let headerHeight = Self.measure(header, width: contentWidth)
        let footerHeight = footer.map { Self.measure($0, width: contentWidth) } ?? 0
        let rowHeights = rows.map { Self.measure($0, width: contentWidth) }
        let groups = paginate(rowHeights: rowHeights, headerHeight: headerHeight, footerHeight: footerHeight)
        return renderPages(groups)
    }

    /// Greedily packs row indices onto pages that each fit within `usableHeight`
    /// after reserving room for the (per-page) header. The footer is guaranteed a
    /// spot on the final page, spilling onto an extra page if the last one is full.
    private func paginate(rowHeights: [CGFloat], headerHeight: CGFloat, footerHeight: CGFloat) -> [[Int]] {
        var pages: [[Int]] = []
        var current: [Int] = []
        var used = headerHeight
        for (index, height) in rowHeights.enumerated() {
            if !current.isEmpty && used + spacing + height > usableHeight {
                pages.append(current)
                current = []
                used = headerHeight
            }
            used += spacing + height
            current.append(index)
        }
        if !current.isEmpty || pages.isEmpty {
            pages.append(current)
        }

        // Ensure the last-page footer has room; otherwise give it its own page.
        if footer != nil {
            let last = pages[pages.count - 1]
            let lastUsed = headerHeight + last.reduce(0) { $0 + spacing + rowHeights[$1] }
            if !last.isEmpty && lastUsed + spacing + footerHeight > usableHeight {
                pages.append([])
            }
        }
        return pages
    }

    private func renderPages(_ groups: [[Int]]) -> Data? {
        let data = NSMutableData()
        guard let consumer = CGDataConsumer(data: data) else { return nil }
        var pageBox = CGRect(origin: .zero, size: pageSize)
        guard let context = CGContext(consumer: consumer, mediaBox: &pageBox, nil) else { return nil }

        for (pageIndex, group) in groups.enumerated() {
            let renderer = ImageRenderer(content: page(for: group, isLast: pageIndex == groups.count - 1))
            renderer.proposedSize = ProposedViewSize(width: pageSize.width, height: pageSize.height)
            context.beginPDFPage(nil)
            renderer.render { _, drawInto in drawInto(context) }
            context.endPDFPage()
        }
        context.closePDF()
        return data as Data
    }

    private func page(for group: [Int], isLast: Bool) -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            header
            ForEach(group, id: \.self) { rows[$0] }
            Spacer(minLength: 0)
            if isLast, let footer {
                footer
            }
        }
        .padding(margin)
        .frame(width: pageSize.width, height: pageSize.height, alignment: .topLeading)
        .background(Color.white)
    }

    /// Measures the intrinsic height a view occupies at a fixed width.
    private static func measure(_ view: AnyView, width: CGFloat) -> CGFloat {
        let renderer = ImageRenderer(content: view.frame(width: width, alignment: .leading))
        renderer.proposedSize = ProposedViewSize(width: width, height: nil)
        var height: CGFloat = 0
        renderer.render { size, _ in height = size.height }
        return height
    }
}
