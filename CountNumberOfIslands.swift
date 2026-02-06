//
//  CountNumberOfIslands.swift
//  DeleteItProj
//
//  Created by Kundan Kumar on 06/02/26.
//

import SwiftUI

struct AnimatedIslandView: View {
    // 1 = Land, 0 = Water, 2 = Currently Processing (Visual Aid)
    @State private var grid: [[Int]] = [
        [1, 1, 0, 0, 0],
        [1, 1, 0, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 0, 1, 1]
    ]
    @State private var islandCount = 0
    @State private var isCalculating = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Island Discovery")
                .font(.largeTitle.bold())
            
            Text("Islands Found: \(islandCount)")
                .font(.title2.monospacedDigit())
                .foregroundColor(.green)

            // The Grid
            VStack(spacing: 4) {
                ForEach(0..<grid.count, id: \.self) { r in
                    HStack(spacing: 4) {
                        ForEach(0..<grid[0].count, id: \.self) { c in
                            Rectangle()
                                .fill(colorFor(grid[r][c]))
                                .frame(width: 50, height: 50)
                                .cornerRadius(4)
                                .animation(.easeInOut(duration: 0.3), value: grid[r][c])
                        }
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            Button(action: {
                Task { await startCalculation() }
            }) {
                Text(isCalculating ? "Searching..." : "Start Animation")
                    .bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isCalculating)
            .padding(.horizontal)
            
            Button("Reset Grid") {
                resetGrid()
            }
            .disabled(isCalculating)
        }
        .padding()
    }

    // MARK: - Animation Logic
    func colorFor(_ value: Int) -> Color {
        switch value {
        case 1: return .green       // Land
        case 2: return .orange      // "Sinking" in progress
        default: return .blue.opacity(0.3) // Water
        }
    }

    func resetGrid() {
        grid = [
            [1, 1, 0, 0, 0],
            [1, 1, 0, 0, 0],
            [0, 0, 1, 0, 0],
            [0, 0, 0, 1, 1]
        ]
        islandCount = 0
    }

    // Async main loop to allow the UI to refresh
    @MainActor
    func startCalculation() async {
        isCalculating = true
        islandCount = 0
        
        for r in 0..<grid.count {
            for c in 0..<grid[0].count {
                if grid[r][c] == 1 {
                    islandCount += 1
                    await sinkIsland(r, c)
                }
            }
        }
        isCalculating = false
    }

    // Recursive DFS with delays for visual effect
    @MainActor
    func sinkIsland(_ r: Int, _ c: Int) async {
        // Boundary and water checks
        if r < 0 || c < 0 || r >= grid.count || c >= grid[0].count || grid[r][c] != 1 {
            return
        }

        // Highlight the current cell being "sunk"
        grid[r][c] = 2
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 second delay
        
        // Finalize sinking to water
        grid[r][c] = 0
        
        // Visit neighbors sequentially
        await sinkIsland(r + 1, c)
        await sinkIsland(r - 1, c)
        await sinkIsland(r, c + 1)
        await sinkIsland(r, c - 1)
    }
}

#Preview {
    AnimatedIslandView()
}

class Solution {
    func numIslands(_ grid: [[String]]) -> Int {
        var grid = grid
        var count = 0
        
        for r in 0..<grid.count {
            for c in 0..<grid[0].count {
                if grid[r][c] == "1" {
                    count += 1
                    dfs(&grid, r, c)
                }
            }
        }
        return count
    }
    
    private func dfs(_ grid: inout [[String]], _ r: Int, _ c: Int) {
        // Check boundaries and if cell is land
        guard r >= 0, r < grid.count, c >= 0, c < grid[0].count, grid[r][c] == "1" else {
            return
        }
        
        // Mark as visited by sinking the island
        grid[r][c] = "0"
        
        // Recursively visit neighbors
        dfs(&grid, r + 1, c) // Down
        dfs(&grid, r - 1, c) // Up
        dfs(&grid, r, c + 1) // Right
        dfs(&grid, r, c - 1) // Left
    }
}
