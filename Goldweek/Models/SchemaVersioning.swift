//
//  SchemaVersioning.swift
//  Goldweek
//
//  SwiftData VersionedSchema + SchemaMigrationPlan
//  3-Layer Data Protection: Schema Migration (Layer 1)
//

import Foundation
import SwiftData

// MARK: - Schema Version 1.0.5 (Current)

enum LeaveWiseSchemaV1_0_5: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 5)
    
    static var models: [any PersistentModel.Type] {
        [UserProfile.self, LeaveRecord.self, BonusLeave.self]
    }
}

// MARK: - Legacy Schema V1 (for backward compatibility)

enum LeaveWiseSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    @Model
    final class UserProfile {
        var id: UUID
        var name: String
        var yearStartMonth: Int
        var totalAnnualLeave: Double
        var usedLeave: Double
        var createdAt: Date
        var countryRaw: String
        var preferredDurationRaw: String
        var preferredSeasonsRaw: String
        var preferLongWeekend: Bool
        var preferConsecutive: Bool
        var avoidPeakSeason: Bool
        var priorityActivitiesRaw: String
        
        init(
            name: String = "",
            yearStartMonth: Int = 1,
            totalAnnualLeave: Double = 15,
            usedLeave: Double = 0,
            countryRaw: String = "korea"
        ) {
            self.id = UUID()
            self.name = name
            self.yearStartMonth = yearStartMonth
            self.totalAnnualLeave = totalAnnualLeave
            self.usedLeave = usedLeave
            self.createdAt = Date()
            self.countryRaw = countryRaw
            self.preferredDurationRaw = "mixed"
            self.preferredSeasonsRaw = ""
            self.preferLongWeekend = true
            self.preferConsecutive = false
            self.avoidPeakSeason = false
            self.priorityActivitiesRaw = ""
        }
    }
    
    @Model
    final class LeaveRecord {
        var id: UUID
        var startDate: Date
        var endDate: Date
        var typeRaw: String
        var statusRaw: String
        var note: String
        var isRecommended: Bool
        
        init(
            startDate: Date,
            endDate: Date,
            typeRaw: String = "연차",
            statusRaw: String = "예정",
            note: String = "",
            isRecommended: Bool = false
        ) {
            self.id = UUID()
            self.startDate = startDate
            self.endDate = endDate
            self.typeRaw = typeRaw
            self.statusRaw = statusRaw
            self.note = note
            self.isRecommended = isRecommended
        }
    }
    
    @Model
    final class BonusLeave {
        var id: UUID
        var days: Double
        var typeRaw: String
        var reason: String
        var grantedDate: Date
        var expirationDate: Date?
        var isUsed: Bool
        
        init(
            days: Double,
            typeRaw: String,
            reason: String = "",
            grantedDate: Date = Date(),
            expirationDate: Date? = nil
        ) {
            self.id = UUID()
            self.days = days
            self.typeRaw = typeRaw
            self.reason = reason
            self.grantedDate = grantedDate
            self.expirationDate = expirationDate
            self.isUsed = false
        }
    }
    
    static var models: [any PersistentModel.Type] {
        [UserProfile.self, LeaveRecord.self, BonusLeave.self]
    }
}

// MARK: - Migration Plan

enum LeaveWiseMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [LeaveWiseSchemaV1.self, LeaveWiseSchemaV1_0_5.self]
    }
    
    static var stages: [MigrationStage] {
        [
            // V1.0.0 -> V1.0.5 (lightweight migration - no schema changes, just version bump)
            .lightweight(fromVersion: LeaveWiseSchemaV1.self, toVersion: LeaveWiseSchemaV1_0_5.self),
            
            // Future migrations can be added here:
            // .custom(fromVersion: LeaveWiseSchemaV1_0_5.self, toVersion: LeaveWiseSchemaV1_1_0.self) { context in
            //     // Custom migration logic if needed
            // }
        ]
    }
}
