//
//  EmotionGraphView.swift
//  FutureLetter
//
//  Created by Chaemin Yu on 12/1/25.
//

import SwiftUI

struct EmotionGraphView: View {
    @EnvironmentObject var stats: EmotionStatsStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("감정 변화 그래프")
                .font(.headline)
            
            if stats.emotionPoints.isEmpty {
                Text("데이터 없음")
                    .foregroundColor(.gray)
            } else {
                
                GeometryReader { geo in
                    ZStack {
                        let points = stats.emotionPoints
                        let maxScore = 1.0
                        let minScore = -1.0
                        
                        // MARK: - Line Path
                        Path { path in
                            for (index, point) in points.enumerated() {
                                let x = geo.size.width * CGFloat(index) / CGFloat(points.count - 1)
                                let ratio = CGFloat((point.score - minScore) / (maxScore - minScore))
                                let y = geo.size.height * (1 - ratio)
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(Color.yellow, lineWidth: 2)
                        
                        
                        // MARK: - Dots on the Line
                        ForEach(Array(points.enumerated()), id: \.offset) { (index, point) in
                            let x = geo.size.width * CGFloat(index) / CGFloat(points.count - 1)
                            let ratio = CGFloat((point.score - minScore) / (maxScore - minScore))
                            let y = geo.size.height * (1 - ratio)
                            
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 8, height: 8)
                                .position(x: x, y: y)
                        }
                    }
                }
                .frame(height: 140)
                
                
                // MARK: - X축 날짜 출력
                HStack {
                    ForEach(stats.emotionPoints) { point in
                        Text(point.date)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical)
    }
    
    
    // 날짜 포맷 MM/dd
    func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd"
        return fmt.string(from: date)
    }
}
