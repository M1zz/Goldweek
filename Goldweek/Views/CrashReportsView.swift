//
//  CrashReportsView.swift
//  Goldweek
//
//  개발자(마스터 모드) 전용 — LeeoDiagnostics(MetricKit)가 허브에 올린 크래시·멈춤 진단을 읽는다.
//  (설정 > 지원 > 안정성)
//
//  이 화면이 답해야 하는 질문은 하나다: **"이번 버전에서 크래시가 늘었나?"**
//  그래서 버전별 건수를 먼저 보여주고 상세는 그 아래에 둔다.
//
//  ⚠️ MetricKit 페이로드는 iOS가 하루 한 번꼴로 묶어서 준다 → 방금 난 크래시는 여기 없다.
//     즉시 확인은 Firebase Crashlytics 대시보드가 맡는다. 이 화면은 "앱 안에서 보는 추세"다.
//  ⚠️ 시뮬레이터에서는 거의 안 올라온다. 실기기 + 사용자 규모가 있어야 쌓인다.
//  ⚠️ 사용자에게 보이지 않는 개발자 화면이라 번역하지 않는다(`Text(verbatim:)`).
//

import SwiftUI
import CloudKit
import LeeoKit

struct CrashReportsView: View {
    @State private var reports: [LeeoCrashReport] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    /// "복사했어요" 알림 문구 — nil이면 안 보인다.
    @State private var copiedNotice: String?

    var body: some View {
        List {
            if isLoading && reports.isEmpty {
                HStack(spacing: 10) {
                    ProgressView()
                    Text(verbatim: "불러오는 중…")
                        .foregroundStyle(.secondary)
                }
            } else if let errorMessage {
                Section {
                    Text(verbatim: errorMessage)
                        .foregroundStyle(.secondary)
                }
            } else if reports.isEmpty {
                Section {
                    Text(verbatim: "아직 올라온 진단이 없어요. 크래시 정보는 iOS가 하루 한 번꼴로 묶어서 보내기 때문에 방금 난 크래시는 바로 보이지 않습니다.")
                        .foregroundStyle(.secondary)
                }
            } else {
                versionSection
                detailSection
            }
        }
        .navigationTitle(Text(verbatim: "안정성"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !reports.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        copy(allReportsText, label: "전체 복사")
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .accessibilityLabel(Text(verbatim: "전체 복사"))
                }
            }
        }
        // 복사한 것을 알린다 — 눌렀는데 아무 일도 안 일어나면 안 된 줄 안다.
        .overlay(alignment: .bottom) {
            if let copiedNotice {
                Text(verbatim: copiedNotice)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.black.opacity(0.75)))
                    .padding(.bottom, 24)
                    .transition(.opacity)
            }
        }
        .task { await load() }
        .refreshable { await load() }
    }

    // MARK: - 버전별 건수 ("이번 버전에서 늘었나")

    private var versionSection: some View {
        let grouped = Dictionary(grouping: reports, by: \.appVersion)
            .map { (version: $0.key, count: $0.value.count) }
            .sorted { $0.version > $1.version }

        return Section {
            ForEach(grouped, id: \.version) { row in
                HStack {
                    Text(verbatim: row.version)
                        .fontWeight(.medium)
                    Spacer()
                    Text(verbatim: "\(row.count)건")
                        .font(.body.monospacedDigit())
                        .foregroundStyle(row.count > 0 ? .orange : .secondary)
                }
                .accessibilityElement(children: .combine)
            }
        } header: {
            Text(verbatim: "버전별 진단 건수")
        }
    }

    // MARK: - 최근 진단

    private var detailSection: some View {
        Section {
            ForEach(reports.prefix(50)) { report in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(verbatim: kindLabel(report.kind))
                            .fontWeight(.medium)
                        Spacer()
                        Text(verbatim: report.appVersion)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        // 이 진단 하나만 복사 — 콜스택을 펼쳐 손으로 긁지 않아도 된다.
                        Button {
                            copy(copyText(report), label: "복사")
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text(verbatim: "이 진단 복사"))
                    }
                    Text(verbatim: "\(report.deviceType) · iOS \(report.osVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !report.detail.isEmpty, report.detail != "-" {
                        Text(verbatim: report.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    // 콜스택은 길어서 접어둔다 — 필요할 때만 펼쳐 본다.
                    DisclosureGroup {
                        Text(verbatim: report.stack)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    } label: {
                        Text(verbatim: "콜스택")
                            .font(.caption)
                    }
                }
                .padding(.vertical, 2)
            }
        } header: {
            Text(verbatim: "최근 진단")
        } footer: {
            Text(verbatim: "MetricKit이 보내주는 익명 진단이에요. 콜스택·앱 버전·OS·기기 종류만 담기고 사용자 정보나 설치 식별자는 들어가지 않습니다.")
        }
    }

    // MARK: - 복사

    private func kindLabel(_ kind: String) -> String {
        switch kind {
        case "crash": return "크래시"
        case "hang": return "멈춤"
        case "disk_write": return "과도한 디스크 쓰기"
        default: return kind
        }
    }

    /// 진단 하나를 그대로 붙여넣을 수 있는 글로.
    /// ⚠️ 화면에 보이는 것과 **같은 것**을 담는다 — 복사한 글이 화면보다 적으면 결국 스크린샷을 다시 찍게 된다.
    private func copyText(_ report: LeeoCrashReport) -> String {
        var lines = ["[\(kindLabel(report.kind))] \(report.appVersion)"]
        if let createdAt = report.createdAt {
            lines.append(DateFormatter.localizedString(from: createdAt, dateStyle: .medium, timeStyle: .short))
        }
        lines.append("\(report.deviceType) · iOS \(report.osVersion)")
        if !report.detail.isEmpty, report.detail != "-" { lines.append(report.detail) }
        lines.append("")
        lines.append(report.stack)
        return lines.joined(separator: "\n")
    }

    /// 화면에 있는 것을 통째로 — 버전별 건수 요약 + 진단 목록.
    private var allReportsText: String {
        let grouped = Dictionary(grouping: reports, by: \.appVersion)
            .map { "\($0.key): \($0.value.count)" }
            .sorted(by: >)
        var out = ["버전별 진단 건수"]
        out.append(contentsOf: grouped)
        out.append("")
        out.append(contentsOf: reports.prefix(50).map(copyText))
        return out.joined(separator: "\n")
    }

    private func copy(_ text: String, label: String) {
        UIPasteboard.general.string = text
        HapticFeedback.success()
        withAnimation(.easeOut(duration: 0.15)) { copiedNotice = "\(label) 완료" }
        Task {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            withAnimation(.easeOut(duration: 0.2)) { copiedNotice = nil }
        }
    }

    // MARK: - Load

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            reports = try await LeeoDiagnosticsReader.fetch(spec: GoldweekSpec.self)
        } catch let error as CKError where error.code == .unknownItem || error.code == .invalidArguments {
            // 서버 원문("Did not find record type: CrashReport")을 그대로 띄우면 앱이 고장난 것처럼 보인다.
            // 진단이 한 건도 안 올라온 컨테이너에서는 이게 정상 상태다 — 무엇을 해야 하는지로 바꿔 말한다.
            reports = []
            errorMessage = "진단 스키마가 아직 허브에 배포되지 않았어요. CloudKit Dashboard에서 CrashReport 레코드 타입과 인덱스를 배포하면 여기에 쌓입니다. (docs/USAGE_STATS_HUB.md)"
        } catch {
            errorMessage = "불러오지 못했어요: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
