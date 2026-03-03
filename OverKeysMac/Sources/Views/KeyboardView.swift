// KeyboardView.swift
// Lays out all key rows for the active layout.
// Supports Staggered, Matrix, and Split Matrix rendering modes.

import SwiftUI

struct KeyboardView: View {

    @ObservedObject var viewModel: KeyboardViewModel

    private var prefs: AppPreferences { viewModel.preferences }

    private var layout: KeyboardLayout {
        let active = viewModel.activeLayout
        // When Glove80 style is selected, the layout must use the 7-row Glove80
        // structure (rows 0-6 with 12/12/12/12/10/4/6 keys). Fall back to the
        // built-in Glove80 base layer for any standard 5-row layout so the renderer
        // always receives correctly shaped data.
        if prefs.keymapStyle == .glove80, active.keys.count < 7 {
            return KeyboardLayout.glove80
        }
        return active
    }

    // MARK: - Body

    var body: some View {
        Group {
            switch prefs.keymapStyle {
            case .staggered:   staggeredLayout
            case .matrix:      matrixLayout
            case .splitMatrix: splitMatrixLayout
            case .glove80:     glove80Layout
            }
        }
        .padding(CGFloat(prefs.keyPadding) * 2)
        .background(Color.clear)
        .opacity(prefs.opacity)  // also applied at window level — this is the content opacity
    }

    // MARK: - Staggered layout

    @ViewBuilder
    private var staggeredLayout: some View {
        VStack(alignment: .leading, spacing: CGFloat(prefs.keyPadding)) {
            ForEach(visibleRows.indices, id: \.self) { rowIdx in
                let row = visibleRows[rowIdx]
                HStack(spacing: CGFloat(prefs.keyPadding)) {
                    // Row stagger: each row is offset slightly to the right
                    let offset = KeyboardLayout.staggerOffset(forRow: rowIdx)
                    Spacer()
                        .frame(width: CGFloat(prefs.keySize) * offset)
                        .fixedSize()

                    ForEach(row.indices, id: \.self) { colIdx in
                        let key = row[colIdx]
                        KeyView(
                            keyID:     key,
                            isPressed: isKeyPressed(key),
                            prefs:     prefs
                        )
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    // MARK: - Matrix layout (ortholinear, no row offset)

    @ViewBuilder
    private var matrixLayout: some View {
        VStack(spacing: CGFloat(prefs.keyPadding)) {
            ForEach(visibleRows.indices, id: \.self) { rowIdx in
                let row = visibleRows[rowIdx]
                HStack(spacing: CGFloat(prefs.keyPadding)) {
                    ForEach(row.indices, id: \.self) { colIdx in
                        let key = row[colIdx]
                        KeyView(
                            keyID:     key,
                            isPressed: isKeyPressed(key),
                            prefs:     prefs
                        )
                    }
                }
            }
        }
    }

    // MARK: - Split Matrix layout

    @ViewBuilder
    private var splitMatrixLayout: some View {
        VStack(spacing: CGFloat(prefs.keyPadding)) {
            ForEach(visibleRows.indices, id: \.self) { rowIdx in
                let row = visibleRows[rowIdx]
                let mid = row.count / 2
                HStack(spacing: 0) {
                    // Left half
                    HStack(spacing: CGFloat(prefs.keyPadding)) {
                        ForEach(0..<mid, id: \.self) { colIdx in
                            KeyView(
                                keyID:     row[colIdx],
                                isPressed: isKeyPressed(row[colIdx]),
                                prefs:     prefs
                            )
                        }
                    }
                    // Gap
                    Spacer()
                        .frame(width: CGFloat(prefs.splitWidth))
                        .fixedSize()
                    // Right half
                    HStack(spacing: CGFloat(prefs.keyPadding)) {
                        ForEach(mid..<row.count, id: \.self) { colIdx in
                            KeyView(
                                keyID:     row[colIdx],
                                isPressed: isKeyPressed(row[colIdx]),
                                prefs:     prefs
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Glove80 layout
    //
    // Rendering strategy:
    //   1. Split every row at its midpoint → left half / right half.
    //   2. For rows 0..<glove80MainRowCount render column-first with a per-column
    //      vertical stagger offset (approximates the curved key-well).
    //   3. Row glove80MainRowCount (modifier row) is rendered flat below.
    //   4. Remaining rows are the thumb cluster, also flat, inset to the inner edge.

    /// Current overlay layer name for display and SwiftUI dependency tracking.
    private var overlayName: String { viewModel.layerOverlay?.name ?? "" }

    @ViewBuilder
    private var glove80Layout: some View {
        VStack(spacing: 4) {
            // Layer indicator — shows current overlay layer name
            if !overlayName.isEmpty {
                Text(overlayName)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(Color.orange)
                    )
            }
            HStack(alignment: .top, spacing: CGFloat(prefs.splitWidth)) {
                glove80Half(isLeft: true)
                glove80Half(isLeft: false)
            }
        }
        // Force full view identity change when overlay switches
        .id("glove80_\(overlayName)")
    }

    @ViewBuilder
    private func glove80Half(isLeft: Bool) -> some View {
        // Convert to concrete arrays so subscript indices are always 0-based.
        let rows      = layout.keys
        let mainCount = KeyboardLayout.glove80MainRowCount
        let modCount  = KeyboardLayout.glove80ModRowCount
        let mainRows  = Array(rows.prefix(mainCount))
        let modRows   = Array(rows.dropFirst(mainCount).prefix(modCount))
        let thumbRows = Array(rows.dropFirst(mainCount + modCount))

        let stagger   = isLeft ? KeyboardLayout.glove80LeftStagger
                                : KeyboardLayout.glove80RightStagger
        let ks        = CGFloat(prefs.keySize)
        let kp        = CGFloat(prefs.keyPadding)

        // Maximum upward shift (negative stagger) — used to pre-shift the HStack
        // so the tallest column starts at y=0 within the ZStack.
        let maxUp: CGFloat    = stagger.reduce(0) { $1 < 0 ? max($0, -$1) : $0 }
        // Maximum downward shift (positive stagger) — how far the shortest column drops.
        let maxDown: CGFloat  = stagger.reduce(0) { $1 > 0 ? max($0, $1) : $0 }
        // Height of one fully-populated column (n rows, n-1 gaps).
        let colHeight: CGFloat = CGFloat(mainRows.count) * (ks + kp) - kp
        // ZStack height must accommodate HStack pre-shift + all individual offsets.
        let bodyHeight: CGFloat = colHeight + maxUp + maxDown

        VStack(alignment: isLeft ? .leading : .trailing, spacing: kp) {

            // ── Column-staggered main body (rows 0–3) ──────────────────────────
            ZStack(alignment: .topLeading) {
                // Transparent frame that reserves the correct height so the outer
                // VStack knows how much space the staggered body occupies.
                Color.clear.frame(width: 0, height: bodyHeight)

                // Render columns first; apply per-column vertical stagger via offset.
                HStack(alignment: .top, spacing: kp) {
                    let colCount = mainRows.map { halfCount($0, isLeft: isLeft) }.max() ?? 6
                    ForEach(0..<colCount, id: \.self) { col in
                        let yOff = col < stagger.count ? stagger[col] : 0
                        VStack(spacing: kp) {
                            ForEach(mainRows.indices, id: \.self) { rowIdx in
                                let half = halfKeys(mainRows[rowIdx], isLeft: isLeft)
                                if col < half.count, !half[col].isEmpty {
                                    let baseKey = half[col]
                                    let olabel  = gloveOverlayLabel(base: baseKey, rowIdx: rowIdx, col: col, isLeft: isLeft)
                                    let badge   = symbolBadgeLabel(base: baseKey, rowIdx: rowIdx, col: col, isLeft: isLeft)
                                    KeyView(
                                        keyID:          baseKey,
                                        isPressed:      isKeyPressed(olabel ?? baseKey),
                                        prefs:          prefs,
                                        overlayLabel:   olabel,
                                        secondaryLabel: badge
                                    )
                                } else {
                                    Color.clear.frame(width: ks, height: ks)
                                }
                            }
                        }
                        .offset(y: yOff)
                    }
                }
                // Pre-shift so the highest column (most negative stagger) aligns to y=0.
                .offset(y: maxUp)
            }

            // ── Flat modifier row (row 4) ───────────────────────────────────────
            // Mod row has 5 keys vs 6 columns in main body.
            // Pad with invisible spacer on the INNER side so keys stay flush
            // with the outer edge: Magic under col-1 (left), PGDN under col-6 (right).
            ForEach(modRows.indices, id: \.self) { rowIdx in
                let half = halfKeys(modRows[rowIdx], isLeft: isLeft)
                HStack(spacing: kp) {
                    // Right half: invisible spacer on left (inner) to push keys right
                    if !isLeft {
                        Color.clear.frame(width: ks, height: ks)
                    }
                    ForEach(half.indices, id: \.self) { colIdx in
                        let key = half[colIdx]
                        if !key.isEmpty {
                            let olabel = gloveOverlayLabel(base: key, rowIdx: mainCount + rowIdx, col: colIdx, isLeft: isLeft)
                            let badge  = symbolBadgeLabel(base: key, rowIdx: mainCount + rowIdx, col: colIdx, isLeft: isLeft)
                            KeyView(keyID: key, isPressed: isKeyPressed(olabel ?? key), prefs: prefs, overlayLabel: olabel, secondaryLabel: badge)
                        } else {
                            Color.clear.frame(width: ks, height: ks)
                        }
                    }
                    // Left half: invisible spacer on right (inner) to keep keys left
                    if isLeft {
                        Color.clear.frame(width: ks, height: ks)
                    }
                }
            }

            // ── Thumb cluster (rows 5–6) ────────────────────────────────────────
            // Parent VStack alignment (.leading for left, .trailing for right)
            // pushes thumb rows to the correct outer edge automatically.
            VStack(alignment: isLeft ? .leading : .trailing, spacing: kp) {
                ForEach(thumbRows.indices, id: \.self) { rowIdx in
                    let half = halfKeys(thumbRows[rowIdx], isLeft: isLeft)
                    HStack(spacing: kp) {
                        ForEach(half.indices, id: \.self) { colIdx in
                            let key = half[colIdx]
                            if !key.isEmpty {
                                let olabel = gloveOverlayLabel(base: key, rowIdx: mainCount + modCount + rowIdx, col: colIdx, isLeft: isLeft)
                                let badge  = symbolBadgeLabel(base: key, rowIdx: mainCount + modCount + rowIdx, col: colIdx, isLeft: isLeft)
                                KeyView(keyID: key, isPressed: isKeyPressed(olabel ?? key), prefs: prefs, overlayLabel: olabel, secondaryLabel: badge)
                            }
                        }
                    }
                }
            }
            .padding(.top, kp * 2)
        }
    }

    // MARK: - Glove80 helpers

    /// Keys belonging to the requested half of a combined row.
    private func halfKeys(_ row: [String], isLeft: Bool) -> [String] {
        let mid = row.count / 2
        return isLeft ? Array(row.prefix(mid)) : Array(row.suffix(from: mid))
    }

    /// Number of non-empty columns in the requested half.
    private func halfCount(_ row: [String], isLeft: Bool) -> Int {
        halfKeys(row, isLeft: isLeft).count
    }

    /// Returns the overlay label for a Glove80 key if the active layer maps
    /// that position to a different (non-empty) key; otherwise nil.
    /// - Parameters:
    ///   - baseKey: the base label at this position
    ///   - rowIdx:  absolute row index in the full layout (0-6)
    ///   - col:     column index within the half (0-5)
    ///   - isLeft:  which half
    private func gloveOverlayLabel(base baseKey: String,
                                   rowIdx: Int,
                                   col: Int,
                                   isLeft: Bool) -> String? {
        guard let overlay = viewModel.layerOverlay else { return nil }
        guard rowIdx < overlay.keys.count else { return nil }
        let half = halfKeys(overlay.keys[rowIdx], isLeft: isLeft)
        guard col < half.count else { return nil }
        let ok = half[col]
        return (!ok.isEmpty && ok != baseKey) ? ok : nil
    }

    /// Returns the TK Symbol layer label for a key position if it differs from
    /// the base label. Used for corner badge display on the base overlay.
    private func symbolBadgeLabel(base baseKey: String,
                                  rowIdx: Int,
                                  col: Int,
                                  isLeft: Bool) -> String? {
        guard prefs.showSymbolBadge else { return nil }
        guard viewModel.layerOverlay == nil else { return nil }
        guard let symbol = viewModel.symbolLayer else { return nil }
        guard rowIdx < symbol.keys.count else { return nil }
        let half = halfKeys(symbol.keys[rowIdx], isLeft: isLeft)
        guard col < half.count else { return nil }
        let sk = half[col]
        return (!sk.isEmpty && sk != baseKey) ? sk : nil
    }

    // MARK: - Row filtering

    private var visibleRows: [[String]] {
        var rows = layout.keys

        // Glove80 uses its own row structure — skip standard filtering
        guard prefs.keymapStyle != .glove80 else { return rows }

        // Optionally hide top (numbers) row
        if !prefs.showTopRow && !rows.isEmpty {
            rows.removeFirst()
        }

        // Optionally hide grave key (first key in top row)
        if prefs.showTopRow && prefs.showGraveKey == false,
           let first = rows.first, !first.isEmpty {
            var topRow = first
            topRow.removeFirst()
            rows[0] = topRow
        }

        return rows
    }

    // MARK: - Key press matching

    /// Returns true if the key should be shown as pressed.
    /// Matches against canonical label AND shifted / aliased variants.
    private func isKeyPressed(_ keyID: String) -> Bool {
        let upper = keyID.uppercased()

        if viewModel.pressedKeys.contains(keyID)  { return true }
        if viewModel.pressedKeys.contains(upper)  { return true }

        // Space aliases
        if upper == " " || upper == "SPC" || upper == "SPACE" {
            return viewModel.pressedKeys.contains(" ")
                || viewModel.pressedKeys.contains("SPC")
                || viewModel.pressedKeys.contains("SPACE")
        }

        // WIN key alias
        if upper == "WIN" || upper == "CMD" {
            return viewModel.pressedKeys.contains("WIN")
                || viewModel.pressedKeys.contains("CMD")
        }

        return false
    }
}

// MARK: - Permissions overlay

/// Shown inside the keyboard area when permissions are missing.
struct PermissionsOverlayView: View {
    @ObservedObject var viewModel: KeyboardViewModel

    var body: some View {
        if !viewModel.hasRequiredPermissions {
            PermissionsView(viewModel: viewModel)
                .transition(.opacity)
        }
    }
}

#Preview {
    KeyboardView(viewModel: KeyboardViewModel())
        .frame(width: 900, height: 220)
        .background(Color.black.opacity(0.9))
}
