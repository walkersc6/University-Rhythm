//
//  RewardsView.swift
//  University Rhythm
//
//  Created by Claude on 10/18/25.
//

import SwiftUI

// MARK: - Reward Model

struct Reward: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let pointsRequired: Int
    let description: String
}

// MARK: - Rewards View

struct RewardsView: View {
    @StateObject private var viewModel = RoadmapViewModel()
    @State private var userPoints: Int = 0
    @State private var isLoading = true
    @State private var scrollOffset: CGFloat = 0

    private let maxPoints = 60

    private let rewards: [Reward] = [
        Reward(name: "BYU Socks", icon: "🧦", pointsRequired: 15, description: "Comfy BYU branded socks"),
        Reward(name: "BYU Hat", icon: "🧢", pointsRequired: 30, description: "Show your school spirit"),
        Reward(name: "BYU Hoodie", icon: "👕", pointsRequired: 45, description: "Stay warm in style"),
        Reward(name: "BYU Ice Cream", icon: "🍦", pointsRequired: 60, description: "Free ice cream voucher")
    ]

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.87, green: 0.95, blue: 1.0),
                    Color(red: 0.7, green: 0.85, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else {
                HStack(spacing: 0) {
                    // Left side: Vertical Progress Bar
                    VerticalProgressBar(
                        currentPoints: userPoints,
                        maxPoints: maxPoints,
                        rewards: rewards,
                        scrollOffset: scrollOffset
                    )
                    .frame(width: 100)
                    .padding(.leading, 20)

                    // Right side: Scrollable Rewards
                    ScrollView {
                        VStack(spacing: 40) {
                            // Header
                            VStack(spacing: 8) {
                                Text("Your Rewards")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.primary)

                                Text("\(userPoints) / \(maxPoints) Points")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 40)

                            // Rewards list
                            ForEach(Array(rewards.enumerated()), id: \.element.id) { index, reward in
                                RewardCard(
                                    reward: reward,
                                    userPoints: userPoints,
                                    isUnlocked: userPoints >= reward.pointsRequired
                                )
                                .id(index)
                            }

                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .background(GeometryReader { geometry in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).minY
                            )
                        })
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                    }
                }
            }
        }
        .navigationTitle("Rewards")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadUserProgress()
        }
    }

    // MARK: - Load User Progress

    private func loadUserProgress() async {
        isLoading = true

        if let progress = await viewModel.fetchUserProgress() {
            userPoints = progress.questions_right?.count ?? 0
        }

        isLoading = false
    }
}

// MARK: - Vertical Progress Bar

struct VerticalProgressBar: View {
    let currentPoints: Int
    let maxPoints: Int
    let rewards: [Reward]
    let scrollOffset: CGFloat

    var progressPercentage: Double {
        min(Double(currentPoints) / Double(maxPoints), 1.0)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                backgroundTrack
                filledProgress(height: geometry.size.height)
                milestoneMarkers(height: geometry.size.height)
            }
        }
        .padding(.vertical, 60)
    }

    private var backgroundTrack: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.3))
            .frame(width: 60)
    }

    private func filledProgress(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 12)
                .fill(progressGradient)
                .frame(width: 60, height: height * progressPercentage)
                .animation(.easeInOut(duration: 0.5), value: progressPercentage)
            Spacer()
        }
    }

    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [Color.blue, Color.blue.opacity(0.7)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func milestoneMarkers(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(rewards.enumerated()), id: \.element.id) { index, reward in
                milestoneMarker(for: reward, at: index, totalHeight: height)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func milestoneMarker(for reward: Reward, at index: Int, totalHeight: CGFloat) -> some View {
        let position = Double(reward.pointsRequired) / Double(maxPoints)
        let isUnlocked = currentPoints >= reward.pointsRequired

        return Group {
            Spacer()
                .frame(height: totalHeight * position - CGFloat(index) * 50.0)

            Circle()
                .fill(isUnlocked ? Color.green : Color.white)
                .frame(width: 30, height: 30)
                .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                .overlay(
                    Text("\(reward.pointsRequired)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(isUnlocked ? .white : .blue)
                )
        }
    }
}

// MARK: - Reward Card

struct RewardCard: View {
    let reward: Reward
    let userPoints: Int
    let isUnlocked: Bool

    var pointsNeeded: Int {
        max(0, reward.pointsRequired - userPoints)
    }

    var body: some View {
        VStack(spacing: 20) {
            rewardIcon
            rewardInfo
            statusBadge
            pointsBadge
        }
        .padding(30)
        .frame(maxWidth: 400)
        .background(cardBackground)
        .overlay(cardBorder)
        .scaleEffect(isUnlocked ? 1.0 : 0.95)
        .animation(.spring(response: 0.3), value: isUnlocked)
    }

    private var rewardIcon: some View {
        ZStack {
            Circle()
                .fill(iconGradient)
                .frame(width: 120, height: 120)
                .shadow(color: isUnlocked ? .blue.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)

            Text(reward.icon)
                .font(.system(size: 60))
                .grayscale(isUnlocked ? 0 : 1)
                .opacity(isUnlocked ? 1 : 0.5)
        }
    }

    private var iconGradient: LinearGradient {
        if isUnlocked {
            return LinearGradient(
                colors: [Color.blue, Color.blue.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var rewardInfo: some View {
        VStack(spacing: 8) {
            Text(reward.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isUnlocked ? .primary : .secondary)

            Text(reward.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        if isUnlocked {
            unlockedBadge
        } else {
            lockedBadge
        }
    }

    private var unlockedBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("Unlocked!")
                .font(.headline)
                .foregroundColor(.green)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.green.opacity(0.1))
        .cornerRadius(20)
    }

    private var lockedBadge: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.orange)
                Text("\(pointsNeeded) more points needed")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }

            miniProgressBar
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(20)
    }

    private var miniProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.orange)
                    .frame(width: progressWidth(geometry.size.width), height: 6)
            }
        }
        .frame(height: 6)
    }

    private func progressWidth(_ totalWidth: CGFloat) -> CGFloat {
        let progress = min(Double(userPoints) / Double(reward.pointsRequired), 1.0)
        return totalWidth * progress
    }

    private var pointsBadge: some View {
        Text("\(reward.pointsRequired) Points")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(isUnlocked ? .blue : .gray)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(badgeBackground)
    }

    private var badgeBackground: some View {
        Capsule()
            .fill(isUnlocked ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(isUnlocked ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
    }
}

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RewardsView()
    }
}
