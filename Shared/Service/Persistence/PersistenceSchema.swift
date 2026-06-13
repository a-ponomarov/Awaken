//
//  PersistenceSchema.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftData

// MARK: - ModelContainer

nonisolated
extension ModelContainer {

  static let main: ModelContainer = {
    let schema = Schema(versionedSchema: MainSchemaV5.self)
    let configuration = ModelConfiguration(
      schema: schema,
      url: URL.applicationSupportDirectory.appending(path: "Main.store"),
      cloudKitDatabase: .none
    )
    return modelContainer(
      schema: schema,
      migrationPlan: MainMigrationPlan.self,
      configurations: [configuration]
    )
  }()

  static let log: ModelContainer = {
    let schema = Schema(versionedSchema: LogSchemaV1.self)
    let configuration = ModelConfiguration(
      schema: schema,
      url: URL.applicationSupportDirectory.appending(path: "Logs.store"),
      cloudKitDatabase: .none
    )
    return modelContainer(
      schema: schema,
      migrationPlan: LogMigrationPlan.self,
      configurations: [configuration]
    )
  }()

  private static func modelContainer(
    schema: Schema,
    migrationPlan: any SchemaMigrationPlan.Type,
    configurations: [ModelConfiguration]
  ) -> ModelContainer {
    do {
      let modelContainer = try ModelContainer(
        for: schema,
        migrationPlan: migrationPlan,
        configurations: configurations
      )
      return modelContainer
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }

}

// MARK: - Main Schema

private enum MainSchemaV1: VersionedSchema {

  static let versionIdentifier = Schema.Version(1, 0, 0)

  static let models: [any PersistentModel.Type] = [
    Sleep.self, Snapshot.self, User.self
  ]

}

private enum MainSchemaV2: VersionedSchema {

  static let versionIdentifier = Schema.Version(2, 0, 0)

  static let models: [any PersistentModel.Type] = [
    Sleep.self, Snapshot.self, User.self, Dream.self
  ]

}

private enum MainSchemaV3: VersionedSchema {

  static let versionIdentifier = Schema.Version(3, 0, 0)

  static let models: [any PersistentModel.Type] = [
    Sleep.self,
    Snapshot.self,
    User.self,
    Dream.self,
    Time.self
  ]

}

private enum MainSchemaV4: VersionedSchema {

  static let versionIdentifier = Schema.Version(4, 0, 0)

  static let models: [any PersistentModel.Type] = [
    Sleep.self,
    Snapshot.self,
    User.self,
    Dream.self,
    Note.self,
    Time.self
  ]

}

private enum MainSchemaV5: VersionedSchema {

  static let versionIdentifier = Schema.Version(5, 0, 0)

  static let models: [any PersistentModel.Type] = [
    Sleep.self,
    Snapshot.self,
    User.self,
    Dream.self,
    Note.self,
    Time.self,
    QueuedTime.self
  ]

}

private struct MainMigrationPlan: SchemaMigrationPlan {

  static let schemas: [any VersionedSchema.Type] = [
    MainSchemaV1.self,
    MainSchemaV2.self,
    MainSchemaV3.self,
    MainSchemaV4.self,
    MainSchemaV5.self
  ]

  static let stages: [MigrationStage] = []

}

// MARK: - Log Schema

private enum LogSchemaV1: VersionedSchema {

  static let versionIdentifier = Schema.Version(1, 0, 0)

  static let models: [any PersistentModel.Type] = [
    Log.self
  ]

}

private struct LogMigrationPlan: SchemaMigrationPlan {

  static let schemas: [any VersionedSchema.Type] = [LogSchemaV1.self]

  static let stages: [MigrationStage] = []

}
