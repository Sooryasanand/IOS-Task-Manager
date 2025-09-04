# TaskManager

A simple, production-feeling task manager built to demonstrate Object-Oriented Programming (OOP) and Protocol-Oriented Programming (POP) in an iOS app. The app uses SwiftUI, MVVM, an actor-based Repository with JSON persistence, robust validation/error UX, and a comprehensive test suite (unit + UI).

## Features

Task Lists: Create/delete lists (e.g., Inbox, Today, Shopping).

Tasks: Add, rename, delete, set category, priority, and due date.

Sorting:
- Within a section: not-done first, then higher priority first, then earlier due, then earlier created.

Swipe Actions: Rename/Delete for lists & tasks.

Validation & Error UX: Inline validation in sheets + non-blocking error banner for unexpected errors.

Persistence: Actor repository that writes JSON to Application Support using ISO-8601 dates which allows the state to survive relaunch.

Tests: Unit tests for models, repository, view models, sorting, and persistence and two UI tests that verify add/toggle flows and persistence.

## Architecture

MVVM + Repository + Swift Concurrency

- Models (OOP) — Value types with behavior:
  - `BaseTask` owns invariants (non-empty title, valid due) and actions (`rename`, `markCompleted`, `markInProgress`, `reschedule`).
  - `TaskList` manages a named collection (`add`, `replace`, `find`).
- Protocols (POP) — Swappable behavior seams:
  - `TaskProtocol`, `TaskListProtocol`
  - `TaskRepository` (implemented by - `InMemoryTaskRepository`, `FileTaskRepository`)
  - `TaskSortingStrategy` → `DefaultTaskSorting`
- ViewModels — `@MainActor` classes exposing state & methods to SwiftUI, mapping thrown errors to user-visible messages.
- Repository (Actor) — `FileTaskRepository` is an `actor` that serializes mutations and persists via `DiskStore`.
- SwiftUI — Small, composable views (`ContentView`, `TaskListDetail`, `AddListSheet`, `AddTaskSheet`, `ErrorBanner`).

## Persistence Details

- DiskStore writes JSON to Application Support/TaskManager/<filename>.
- Dates use ISO-8601 for stability and testability.
- The app uses:
  ```
  FileTaskRepository(filename: "task_lists.json", seed: Fixtures.makeSeed())
  ```

## Error Handling & Validation

- Domain errors (`TaskError`):
  - `.emptyTitle`, `.invalidDueDate`, `.alreadyCompleted`
- Repository errors (`RepositoryError`):
  - `.listNotFound`, `.taskNotFound`, `.listNameTaken`
- UX:
  - Inline validation disables Add/Save (empty title, past due).
  - A lightweight ErrorBanner surfaces unexpected issues without blocking flows.

## Appendix

### Reflective Report

Goal. Build a small but production-feeling iOS task manager that demonstrates OOP + POP, MVVM with SwiftUI, robust error handling, persistence, and tests.

Key decisions.

- OOP for domain entities. I modeled BaseTask and TaskList as value types with behavior. Encapsulating invariants (non-empty title, valid due date) in the types prevented error-prone duplication in the UI and view models.
- POP for seams. Protocols (TaskProtocol, TaskListProtocol, TaskRepository, TaskSortingStrategy) decoupled the UI from concrete implementations. I can swap the repository (in-memory vs file) or alter sorting without changing views.
- Concurrency via actors. I implemented FileTaskRepository as an actor so all mutations are serialized and safe which simplified threading concerns.
- SwiftUI + MVVM. View models are @MainActor and expose minimal state which they translate thrown errors into friendly messages. Views remain declarative and small.

Error handling approach.

- Validation at core and edge. The UI disables Add/Save for empty titles or past due dates, while the models still enforce invariants and throw TaskError. Repository errors (listNotFound, listNameTaken) appear inline or via a banner.
- UX. Inline field errors preserve flow; banners handle unexpected issues without blocking.

Persistence trade-offs.

- Chose JSON via DiskStore for transparency and speed. ISO-8601 encoding ensures predictable round-trips and easy diffs. For multi-device sync or scale, I’d consider CloudKit or a database.

Testing strategy.

- Unit tests cover model behavior (rename, reschedule, mark completed), validation errors, repository CRUD with error paths, sorting/sections, and a DiskStore round-trip.
- UI tests automate the primary flows (add task, toggle done) and verify persistence across relaunch using an isolated file (PERSISTENCE_FILENAME) and a wipe flag.
- I enabled coverage to confirm models, repository, and view models are well exercised.

Challenges & solutions.

- Date validation in tests. My initial “overdue” sample had dueAt < createdAt, causing a fail. I fixed it by setting createdAt = now - 2h and dueAt = now - 1h—valid object but overdue relative to “now.”

Lessons learned.

- Push validation into the model to keep UI thin and robust.
- Protocol seams are cheap insurance when requirements change.
- Small UX touches—sections, swipe actions, inline validation—make a simple app feel polished.

## License

MIT © Soorya Sanand
